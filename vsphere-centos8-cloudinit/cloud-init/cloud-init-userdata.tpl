#cloud-config 

user: root
password: ${root_password}
chpasswd: {expire: False}
ssh_pwauth: True
ssh_authorized_keys:
 - ${ssh_public_key}


disable_root: false #Enable root access, if you want disable root you need to create more users
#ssh_pwauth: yes #Use pwd to access 

runcmd:
  - echo -n > /etc/machine-id

final_message: "The system is prepped, after $UPTIME seconds"

power_state:
  timeout: 30
  mode: reboot
