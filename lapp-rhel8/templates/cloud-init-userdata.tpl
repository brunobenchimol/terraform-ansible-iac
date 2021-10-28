#cloud-config 

user: root
password: ${root_password}
chpasswd: {expire: False}
ssh_pwauth: True
ssh_authorized_keys:
 - ${ssh_public_key}


disable_root: false #Enable root access, if you want disable root you need to create more users
#ssh_pwauth: yes #Use pwd to access 


%{ if rhn == true }
rh_subscription:
  username: ${rhn_username}
  password: ${rhn_password}
  auto-attach: True
  #if you dont want auto-attach
  #auto-attach: False
  #activation-key: <activation key>
  #add-pool: [ '<poolid>' ]
  #disable-repo: [ '*' ]
  #enable-repo: [ 'rhel-8-for-x86_64-baseos-rpms', 'rhel-8-for-x86_64-appstream-rpms' ]
  # if you want satellite server instead of rhn
  #rhsm-baseurl: <url> 
  #server-hostname: <hostname>

packages:
 - bind-utils 
 - python36
%{ endif }

runcmd:
  - echo -n > /etc/machine-id

final_message: "The system is prepped, after $UPTIME seconds"

power_state:
  timeout: 30
  mode: reboot
