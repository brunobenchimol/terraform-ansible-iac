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
  is_rhn_enabled_cloudinit    = (var.rhn_username != "" && var.force_rhn_enable_cloud_init == "true" ? true : false)
  is_rhn_enabled_ansible      = (var.rhn_username != "" && var.force_rhn_enable_cloud_init == "false" ? true : false)
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

  # You must follow the rhel template preparation
  # only works with cloud-init 21.3+ on vsphere (double check cloud-init guest OS version)  
  extra_config = {
    "guestinfo.metadata" = base64encode(
                                        templatefile(local.metadata_tpl_file,
                                          {
                                            hostname    = "${var.vm_prefix_name}-${resource.random_string.random.result}-${count.index}",
                                            dhcp        = local.is_dhcp_enabled,
                                            # if-else works but try is more clean to read
                                            #ip_address  = "${local.is_dhcp_enabled ? "" : element(var.vm_ipaddress_list, count.index)}",
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
                                            root_password = var.vm_root_password,
                                            rhn = local.is_rhn_enabled_cloudinit,
                                            rhn_username = var.rhn_username,
                                            rhn_password = var.rhn_password
                                          }
                                        )
                                      )
    "guestinfo.userdata.encoding" = "base64"
  }

  # SSH connection config
  connection {
    type     = "ssh"
    port     = "22"
    user     = "root"
    host      = self.default_ip_address
    private_key = file(var.ssh_private_key)
  }

  # Make sure host is up and running to run ansible-playbook
  provisioner "remote-exec" {
    inline = [ "uptime" ]
  }

  # Run commands on local host (start ansible from within terraform)
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.default_ip_address}, --user root --private-key ${var.ssh_private_key} ansible-playbook.yml"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ENABLE_RHN = local.is_rhn_enabled_ansible
      RHN_USERNAME = var.rhn_username
      RHN_PASSWORD = var.rhn_password
    }
  }

}
