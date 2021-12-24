# General Tips

# # EXPORT sensitive variables with TF_VAR_<variable-name> or use a "secret.tfvars" file and apply with -var-file
# It will prompt for user input if you dont want to expose them. Your most sensitive vars are: username / password

#########################
### VSPHERE VARIABLES ###
#########################

vsphere_server = "vcenter.server.example.local"
vsphere_user = "LOGIN"
vsphere_password = "PASS"
vsphere_dcname = "DC_NAME_EXAMPLE"
vsphere_datastore = "DATASTORE_EXAMPLE"
vsphere_cluster = "CLUSTER_EXAMPLE"
vsphere_network = "NETWORK_PORTGROUP_EXAMPLE"
vsphere_library_name = "EXAMPLE_CONTENT_LIBRARY"
vsphere_library_item = "CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64"

######################
### VM's VARIABLES ###
######################

vm_prefix_name = "vm-app-example"
#vm_root_password = "" # default is pa$$w0rd
#vm_cpu = 1
#vm_memory = 2048
#vm_disk0_size = 40
vm_firmware = "efi"
vm_efi_secure_boot_enabled = false

### FOR DHCP USAGE ########
#vm_count = 1
###########################
### FOR STATIC IP USAGE ###
# Network Interface: [ RHEL8: ens3, CentOS8: eth0 ]
# vm_network_interface = "eth0"
vm_ipaddress_list = ["10.1.1.1", "10.1.1.2", "10.1.1.3"]
vm_ipnetmask = "24"
vm_gateway = "10.1.1.254"
vm_dns_servers = ["1.1.1.1", "8.8.8.8"]
vm_domain = ["example.local"]
###########################


#####################
### PKI VARIABLES ###
#####################

# Default to get current user default keys (~/.ssh/id_rsa*)
#ssh_private_key = "path-to-ssh-keys/my-ssh.privkey"
#ssh_public_key = "path-to-ssh-keys/my-ssh.pub"

