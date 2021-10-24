instance-id: ${hostname}
hostname: ${hostname}
local-hostname: ${hostname}

preserve_hostname: false

network:
  version: 2
  ethernets:
    ens192:
      %{ if dhcp == "true" }dhcp4: true
      %{ else }dhcp4: false
      addresses:
        - ${ip_address}/${netmask}
      gateway4: ${gateway}
      nameservers:
        addresses: ${nameservers}
        search: ${domain}
      %{ endif }