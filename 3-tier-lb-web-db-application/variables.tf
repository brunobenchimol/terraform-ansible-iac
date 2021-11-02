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
variable "vsphere_network_lb" {
  description = "Load Balancer Portgroup / Network Name"
  default = ""
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

#############################
### Application VARIABLES ###
#############################

variable "app_prefix_name" {
  description = "Application prefix name to append to VMs" 
}

variable "app_database_disk_size" {
 description = "Database Disk Size (GB)"
 default = 50
}

variable "app_high_availbility" {
 description = "Enable/Disable HA function"
 type = bool
 default = false
}

######################
### VM's VARIABLES ###
######################

variable "vm_root_password" {
  description = "VM Root Password to set"
  default = "pa$$w0rd"
}

variable "vm_web_ipaddress_list" {
  type = list
  description = "IP Address in a List to configure static ip address for Web Servers"
  default = []
} 

variable "vm_lb_ipaddress_list" {
  type = list
  description = "IP Address in a List to configure static ip address for Load Balance Servers"
  default = []
} 

variable "vm_lb_vip_ipaddress" {
  type = string
  description = "IP Address to configure static ip address for Virtual IP (Load Balance)"
  default = ""
} 

variable "vm_lb_ipnetmask" {
  description = "VM Load Balancer IP Netmask"
  default = ""
}

variable "vm_lb_gateway"  {
  description = "VM Load Balancer Gateway IP Address"
  default = ""
}

variable "vm_lb_dns_servers" {
  type = list
  description = "VM Load Balancer - DNS Nameserver List (comma-separated values)"
  default = []
}

variable "vm_lb_domain" {
  type = list
  description = "Load Balancer VM domain name for FQDN and DNS search domain"
  default = []
}

variable "vm_db_ipaddress_list" {
  type = list
  description = "IP Address to configure static ip address for Database Server"
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

variable "vm_web_count" {
  description = "Web VM instance count"
  default = 0
}

variable "vm_web_cpu" {
  description = "Web Server VM CPU count"
  default = 1
}

variable "vm_web_memory" {
  description = "Web Server VM Memory (MB)"
  default = 2048
}

variable "vm_db_cpu" {
  description = "Database VM CPU count"
  default = 1
}

variable "vm_db_memory" {
  description = "Database VM Memory (MB)"
  default = 2048
}

variable "vm_lb_cpu" {
  description = "Load Balancer VM CPU count"
  default = 1
}

variable "vm_lb_memory" {
  description = "Load Balancer VM Memory (MB)"
  default = 2048
}

variable "vm_root_disk_size" {
  description = "VM Disk 0 (root disk) Size (GB)"
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