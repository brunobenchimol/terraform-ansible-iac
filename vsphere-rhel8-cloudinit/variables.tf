#########################
### VSPHERE VARIABLES ###
#########################
variable "vsphere_server"  {
  description = "vCenter/ESXi Server IP"
}
variable "vsphere_user" {
  description = "vCenter/ESXi username"
  type        = string
  sensitive   = true
}
variable "vsphere_password" {
  description = "vCenter/ESXi password"
  type        = string
  sensitive   = true
}
variable "vsphere_datastore" {
  description = "Datastore Name"
}
variable "vsphere_cluster" {
  description = "Cluster Name"
}
variable "vsphere_resoucepool" {
  description = "Resource Pool Name (leave blank for Root)" 
  default = "Resources"
}
variable "vsphere_network" {
  description = "Portgroup / Network Name"
}
variable "vsphere_dcname" {
  description = "Datacenter Name"
}
variable "vsphere_library_name" {
  description = "Content Library Name"
}
variable "vsphere_library_item" {
  description = "Content Library Item"
}
variable "vsphere_library_item_type" {
  description = "Content Library Item Type"
  default = "ovf"
}


#####################
### RHN VARIABLES ###
#####################

variable "force_rhn_enable_cloud_init" {
  description = "Force to Subscribe using Userdata instead of Ansible"
  type = string
  default = "false"
}

variable "rhn_username" {
  description = "RHN/Satellite Username"
  type        = string
  default     = ""
}

variable "rhn_password" {
  description = "RHN/Satellite Password"
  type        = string
  sensitive   = false # if set to true supress ansible output due sensitive value in config and ansible already suppress passwords
  default     = ""
}


######################
### VM's VARIABLES ###
######################

variable "vm_prefix_name" {
  description = "VM prefix name to append to VMs" 
}

variable "vm_root_password" {
  description = "VM Root Password to set"
  default = "pa$$w0rd"
}

variable "vm_ipaddress_list" {
  type = list
  description = "IP Address in a List to configure static ip address"
  default = []
} 

variable "vm_ipnetmask" {
  description = "VM Netmask"
  default = ""
}

variable "vm_gateway"  {
  description = "VM Gateway IP Address"
  default = ""
}

variable "vm_domain" {
  type = list
  description = "VM domain name for FQDN and DNS search domain"
  default = []
}

variable "vm_dns_servers" {
  type = list
  description = "DNS Nameserver List (comma-separated values)"
  default = []
}

variable "vm_count" {
  description = "VM instance count"
  default = 0
}

variable "vm_cpu" {
  description = "VM CPU count"
  default = 1
}

variable "vm_memory" {
  description = "VM Memory (MB)"
  default = 2048
}

variable "vm_disk0_size" {
  description = "VM Disk 0 Size (GB)"
  default = 40
}

variable "vm_firmware" {
  description = "Firmware from VM/OVF - Choose 'bios' or 'efi'"
}

variable "vm_efi_secure_boot_enabled" {
  description = "Enable EFI Secure Boot"
  default = false
}


#####################
### PKI VARIABLES ###
#####################

variable "ssh_private_key" {
  description = "File Path to SSH Private Key (id_rsa)"
  default = "~/.ssh/id_rsa"
}
variable "ssh_public_key" {
  description = "File Path to SSH Public Key (id_rsa.pub)"
  default = "~/.ssh/id_rsa.pub"
}

