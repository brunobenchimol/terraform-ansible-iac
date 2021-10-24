#!/bin/bash

#
### RED HAT CLOUD-INIT PREPATION SCRIPT FOR TEMPLATE
#

# install cloud-init-vmware-guestinfo plugin (DataSourceVMwareGuestInfo.py) -- needed until RH upgrades cloud-init to 21.3
/usr/bin/curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -

# Make sure cloud-init is installed
yum -y install cloud-init

# https://access.redhat.com/blogs/1169563/posts/3640721

# Unregister Virtual Machine from Satellite/RHN
subscription-manager unregister
subscription-manager clean

# stop logging services
/usr/bin/systemctl stop rsyslog
/usr/bin/systemctl stop auditd

# remove old kernels
# /bin/package-cleanup -oldkernels -count=1

#clean yum cache
/usr/bin/yum clean all

#force logrotate to shrink logspace and remove old logs as well as truncate logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

#remove udev hardware rules
/bin/rm -f /etc/udev/rules.d/70*

#remove uuid from ifcfg scripts
/bin/cat > /etc/sysconfig/network-scripts/ifcfg-ens192 <<EOM
DEVICE=ens192
ONBOOT=yes
EOM

#remove SSH host keys
/bin/rm -f /etc/ssh/*key*

#remove root users shell history
/bin/rm -f ~root/.bash_history
unset HISTFILE

#remove root users SSH history
/bin/rm -rf ~root/.ssh/known_hosts

# make sure cloud init is clean if it wsa ran by mistake.
cloud-init clean
userdel cloud-users
rm -f /var/log/cloud-init*
