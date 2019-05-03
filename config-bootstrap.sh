#!/bin/sh

set -e

yum -y upgrade
yum -y install yum-utils epel-release git
yum-config-manager --disable epel
yum --enablerepo=epel -y install ansible

if ! needs-restarting -r; then
  rm -f /var/lib/cloud/instance/sem/config_scripts_user
  reboot
fi

cat > /etc/systemd/system/ansible-pull@.service <<'EOF'
[Service]
Type=oneshot
EnvironmentFile=/etc/ansible/pull/%i/config
ExecStart=/usr/bin/ansible-pull -U ${PULL_REPOSITORY_URL}
EOF

cat > /etc/systemd/system/ansible-pull@.timer <<'EOF'
[Timer]
OnCalendar=hourly
RandomizedDelaySec=600
Persistent=true

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/ansible/pull/moc_grafana
cat > /etc/ansible/pull/moc_grafana/config <<'EOF'
PULL_REPOSITORY_URL=__ansible_repository_url__
EOF

systemctl daemon-reload
systemctl enable --now ansible-pull@moc_grafana.timer
systemctl start ansible-pull@moc_grafana.service
