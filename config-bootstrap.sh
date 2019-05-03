#!/bin/sh

yum -y upgrade
yum -y install yum-utils epel-release git
yum-config-manager --disable epel
yum --enablerepo=epel -y install ansible

if ! needs-restarting -r; then
  rm -f /var/lib/cloud/instance/sem/config_scripts_user
  reboot
fi

exit 0

