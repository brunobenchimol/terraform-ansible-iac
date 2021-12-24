#########################
### NUTANIX VARIABLES ###
#########################

prism_server = "PRISM-CENTRAL-OR-ELEMENT"
prism_user = "PRISM-LOGIN"
prism_password = "PRISM-PASSWORD"

prism_cluster = "NUTANIX-CLUSTER-NAME"
prism_subnet = "VLAN-SUBNET-NAME"
prism_storage = "STORAGE-CONTAINER-NAME"
#prism_image_name = "ubuntu-20.04-server-cloudimg-amd64"
prism_image_name = "CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64"

app_prefix_name = "vm-ntnx"

vm_cpu = 1
vm_memory = 2048
#vm_firmware = "LEGACY" # legacy does not work, empty = legacy = bios
vm_firmware = "UEFI"

# Network Interface: [ RHEL8: ens3, CentOS8: eth0 ]
vm_network_interface = "eth0"

vm_ipaddress_list = ["10.1.1.1"]
vm_ipnetmask = "24"
vm_gateway = "10.1.1.254"
vm_dns_servers = ["1.1.1.1", "8.8.8.8"]
vm_domain = ["example.local"]