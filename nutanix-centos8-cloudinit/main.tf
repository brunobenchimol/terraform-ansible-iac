terraform {
  required_version = ">= 1.0.8"
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 1.2.0"
    }
  }
}

resource "random_string" "random" {
  length           = 5
  number           = true
  lower            = true
  upper            = false
  special          = false
  }

locals {
  #metadata_tpl_file = "${path.module}/templates/cloud-init-metadata.tpl"
  userdata_tpl_file = "${path.module}/cloud-init/cloud-init-userdata-nutanix.tpl"
  vm_instance_count = (local.is_dhcp_enabled ? var.vm_count : length(var.vm_ipaddress_list))
  is_dhcp_enabled   = (var.vm_ipaddress_list != tolist([]) ? false : true)
  vm_prefix_name              = "${var.app_prefix_name}-${terraform.workspace}-${resource.random_string.random.result}"
}

resource "nutanix_virtual_machine" "vm" {
  name                 = "${local.vm_prefix_name}-${count.index}"
  count                = local.vm_instance_count

  cluster_uuid         = data.nutanix_cluster.cluster.id
  # optional
  #num_vcpus_per_socket = "2"
  num_sockets          = var.vm_cpu
  memory_size_mib      = var.vm_memory  

  # unstable - do not set if BIOS, only go UEFI.
  #boot_type = var.vm_firmware

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.image.id
    }
   # Cant set storage container if using data_source_reference
/*     storage_config {
      # disk in ssd ?
      flash_mode = false
      storage_container_reference {
        kind = "storage_container"
        #uuid = "2bbe67bc-fd14-4637-8de1-6379257f4219"
        name = var.prism_storage
      }
    } */
  }

 # comment out if you want a second (disk 2)
 /*  disk_list {
    #disk_size_bytes = var.vm_root_disk_size * 1024 * 1024 * 1024
    disk_size_mib = var.vm_root_disk_size * 1024 

    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }

    storage_config {
      # disk in ssd ?
      flash_mode = false
      storage_container_reference {
        kind = "storage_container"
        #uuid = "2bbe67bc-fd14-4637-8de1-6379257f4219"
        name = var.prism_storage
      }
    }
    
  } */

 # https://github.com/nutanix/terraform-provider-nutanix/issues/303
 # Nutanix only support user-data. Breaks metadata cloudinit
 # guest customization (cloud-init)  
   guest_customization_cloud_init_user_data = base64encode(templatefile(local.userdata_tpl_file, 
                                                   { 
                                                     interface       = var.vm_network_interface,
                                                     hostname        = "${local.vm_prefix_name}-${count.index}",
                                                     dhcp            = local.is_dhcp_enabled,
                                                     ip_address      = element(var.vm_ipaddress_list, count.index),
                                                     netmask         = var.vm_ipnetmask,
                                                     domain          = try(var.vm_domain[0], ""),
                                                     dns1            = try(var.vm_dns_servers[0], ""),
                                                     dns2            = try(var.vm_dns_servers[1], ""),
                                                     dns3            = try(var.vm_dns_servers[2], ""),
                                                     gateway         = var.vm_gateway,
                                                     ssh_public_key  = file(var.ssh_public_key),
                                                     root_password   = var.vm_root_password
                                                   }
                                                )
                                              )
                                              
 /*   
  guest_customization_cloud_init_meta_data = base64encode(jsonencode(
                                                templatefile(local.metadata_tpl_file,
                                                    {
                                                      hostname    = "${local.vm_prefix_name}-${count.index}",
                                                      dhcp        = local.is_dhcp_enabled,
                                                      ip_address  = try(element(var.vm_ipaddress_list, count.index), ""),
                                                      netmask     = var.vm_ipnetmask,
                                                      domain      = jsonencode(var.vm_domain),
                                                      nameservers = jsonencode(var.vm_dns_servers),
                                                      gateway     = var.vm_gateway
                                                    }
                                                  )
                                                )
                                              )  
  guest_customization_cloud_init_user_data = base64encode(jsonencode(
                                                templatefile(local.userdata_tpl_file, 
                                                    { 
                                                      ssh_public_key = file(var.ssh_public_key),
                                                      root_password = var.vm_root_password
                                                    }
                                                  )
                                                )
                                              )                       
 */

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }
}

output "all_vm_ip_address" {
  value = formatlist(
    "%s = %s", 
    (nutanix_virtual_machine.vm[*].name),
    (nutanix_virtual_machine.vm[*].nic_list_status[0].ip_endpoint_list[0]["ip"])
  )
  
  description = "First Network IP address from All VMs"
}