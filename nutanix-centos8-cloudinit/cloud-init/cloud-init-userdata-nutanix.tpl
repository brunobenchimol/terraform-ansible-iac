#cloud-config 

user: root
password: ${root_password}
chpasswd: {expire: False}
ssh_pwauth: True
ssh_authorized_keys:
 - ${ssh_public_key}


disable_root: false #Enable root access, if you want disable root you need to create more users
#ssh_pwauth: yes #Use pwd to access 

# Nutanix bug for metadata, workaround -- see issue #303 on nutanix-provider
# https://cloudinit.readthedocs.io/en/latest/topics/examples.html#writing-out-arbitrary-files
# https://github.com/nutanix/terraform-provider-nutanix/issues/303

write_files:
- content: |
    NAME=${interface}
    DEVICE=${interface}
    ONBOOT=yes
    TYPE=Ethernet
    %{ if dhcp == true }BOOTPROTO=dhcp
    %{ else }BOOTPROTO=none
    IPADDR=${ip_address}
    PREFIX=${netmask}
    GATEWAY=${gateway}
    %{ if dns1 != "" ~}DNS1=${dns1}${"\n"}%{ endif ~}
    %{ if dns2 != "" ~}DNS2=${dns2}${"\n"}%{ endif ~}
    %{ if dns3 != "" ~}DNS3=${dns3}${"\n"}%{ endif ~}
DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no %{ endif }
  path: /etc/sysconfig/network-scripts/ifcfg-${interface}
  owner: root:root
  permissions: '0644'

runcmd:
  - echo -n > /etc/machine-id
  %{ if dhcp != true }- hostnamectl set-hostname ${hostname}.${domain} 
  %{ endif }

final_message: "The system is prepped, after $UPTIME seconds"

power_state:
  timeout: 30
  mode: reboot
