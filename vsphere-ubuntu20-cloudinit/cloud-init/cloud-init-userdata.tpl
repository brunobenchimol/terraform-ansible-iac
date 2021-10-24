#cloud-config 

user: root
password: ${root_password}
chpasswd: {expire: False}
ssh_pwauth: True
ssh_authorized_keys:
 - ${ssh_public_key}

disable_root: false #Enable root access (console access)
#ssh_pwauth: yes #Use pwd to access 

packages:
  - python3
  - net-tools

runcmd:
  # ubuntu does not have it by default
  - 'echo "disable_vmware_customization: false" > /etc/cloud/cloud.cfg.d/99-disable_vmware_cust.cfg' 
  # fix ubuntu cleaning up /tmp every reboot (wait: 10d)
  - sed -i 's/D \/tmp 1777 root root -/D \/tmp 1777 root root 10d/g' /usr/lib/tmpfiles.d/tmp.conf
  - echo -n > /etc/machine-id
  # force to use guestinfo vmx extra_config
  - 'echo "datasource_list: [ "DataSourceVMware" ]" > /etc/cloud/cloud.cfg.d/10-datasource.cfg'



final_message: "The system is prepped, after $UPTIME seconds"

power_state:
  timeout: 30
  mode: reboot
