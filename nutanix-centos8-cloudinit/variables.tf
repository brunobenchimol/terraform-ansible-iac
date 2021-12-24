#########################
### NUTANIX VARIABLES ###
#########################
variable "prism_server"  {
  description = "Prism Central/Element Server IP"
}
variable "prism_user" {
  description = "Prism Central/Element Username"
  type        = string
  sensitive   = true
}
variable "prism_password" {
  description = "Prism Central/Element Password"
  type        = string
  sensitive   = true
}
variable "prism_storage" {
  description = "Storage Container Name"
}
variable "prism_subnet" {
  description = "Nutanix Subnet for VM"
}
variable "prism_cluster" {
  description = "Nutanix Cluster"
}
variable "prism_image_name" {
  description = "Nutanix Image Name (use if not uploaded image on resource)"
  default = ""
}

######################
### VM's VARIABLES ###
######################

variable "app_prefix_name" {
  description = "VM/App prefix name to append to VMs" 
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

variable "vm_root_disk_size" {
  description = "VM Disk 0 Size (GB)"
  default = 40
}

variable "vm_network_interface" {
  description = "VM Net Interface - Default to ens3 on RHEL8/NTNX"
  default = "ens3"
}

variable "vm_firmware" {
  description = "Firmware from VM - Choose '' (BIOS) or 'UEFI' or 'SECURE_BOOT'"
  default = ""
}

/*
variable "vm_efi_secure_boot_enabled" {
  description = "Enable EFI Secure Boot"
  default = false
} */


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

