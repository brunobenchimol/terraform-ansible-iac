terraform {
  required_version = ">= 1.0.8"
  required_providers {
    vsphere = {
      version = ">= 2.0.2"
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
  metadata_tpl_file = "${path.module}/cloud-init/cloud-init-metadata.tpl"
  userdata_tpl_file = "${path.module}/cloud-init/cloud-init-userdata.tpl"
  vm_instance_count = (local.is_dhcp_enabled ? var.vm_count : length(var.vm_ipaddress_list))
  is_dhcp_enabled   = (var.vm_ipaddress_list != tolist([]) ? false : true)
}



resource "vsphere_virtual_machine" "vm" {
  name             = "${var.vm_prefix_name}-${resource.random_string.random.result}-${count.index}"
  count            = local.vm_instance_count

  num_cpus         = var.vm_cpu
  memory           = var.vm_memory

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  
  # Until there is a change on how OVF are handled we must set it
  firmware = var.vm_firmware
  efi_secure_boot_enabled = var.vm_efi_secure_boot_enabled

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = var.vm_disk0_size
  }
  
  clone {
    template_uuid = data.vsphere_content_library_item.library_item.id
   }

  # only works with cloud-init 21.3+ on vsphere (double check cloud-init guest OS version)  
  extra_config = {
    "guestinfo.metadata" = base64encode(
                                        templatefile(local.metadata_tpl_file,
                                          {
                                            hostname    = "${var.vm_prefix_name}-${resource.random_string.random.result}-${count.index}",
                                            dhcp        = local.is_dhcp_enabled,
                                            ip_address  = try(element(var.vm_ipaddress_list, count.index), ""),
                                            netmask     = var.vm_ipnetmask,
                                            domain      = jsonencode(var.vm_domain),
                                            nameservers = jsonencode(var.vm_dns_servers),
                                            gateway     = var.vm_gateway
                                          }
                                        )
                                       )
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(
                                        templatefile(local.userdata_tpl_file, 
                                          { 
                                            ssh_public_key = file(var.ssh_public_key),
                                            root_password = var.vm_root_password
                                          }
                                        )
                                      )
    "guestinfo.userdata.encoding" = "base64"
  }

}

output "vm_ip_address" {
  value = formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.vm.*.name),
    (vsphere_virtual_machine.vm.*.default_ip_address)
  )

  description = "Network IP address from Virtual Machines"
}