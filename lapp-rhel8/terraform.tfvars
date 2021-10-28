# General Tips

# # EXPORT sensitive variables with TF_VAR_<variable-name> or use a "secret.tfvars" file and apply with -var-file
# It will prompt for user input if you dont want to expose them. Your most sensitive vars are: username / password

#########################
### VSPHERE VARIABLES ###
#########################

#vsphere_user = "login_vsphere"
#vsphere_password = "pass"
vsphere_server = "vcenter.gerencia.prodepa.gov.br"
vsphere_dcname = "DC_PRODEPA"
vsphere_datastore = "VNX7602-VMWARE-INFRAESTRUTURA"
vsphere_cluster = "Cluster_Openshift_Staging"
vsphere_network = "SRV_Desenv-10.1.11.0_24"
vsphere_library_name = "PRODEPA_Content_Library"
vsphere_library_item = "Template_Server_RHEL_8.4_x64_CloudInit"


#####################
### RHN VARIABLES ###
#####################

#rhn_username = "email/login"
#rhn_password = "password"
#force_rhn_enable_cloud_init = false


#############################
### Application VARIABLES ###
#############################

app_prefix_name = "lapp"
app_database_disk_size = 20

######################
### VM's VARIABLES ###
######################

# vm_root_password = "" # default is pa$$w0rd
vm_cpu = 1
vm_memory = 2048
vm_root_disk_size = 40
vm_firmware = "efi"
vm_efi_secure_boot_enabled = false

### FOR DHCP USAGE ########
#vm_count = 1
###########################
### FOR STATIC IP USAGE ###
vm_ipaddress_list = ["10.1.11.221"]
vm_ipnetmask = "24"
vm_gateway = "10.1.11.7"
vm_dns_servers = ["10.1.2.3", "10.1.2.5"]
vm_domain = ["rede.local"]
###########################


#####################
### PKI VARIABLES ###
#####################

# Default to get current user default keys (~/.ssh/id_rsa*)
#ssh_private_key = "path-to-ssh-keys/my-ssh.privkey"
#ssh_public_key = "path-to-ssh-keys/my-ssh.pub"