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
   vm_instance_count       = (local.is_dhcp_enabled ? var.vm_count : length(var.vm_ipaddress_list))
  is_dhcp_enabled = (var.vm_ipaddress_list != tolist([]) ? false : true)
}

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.vm_prefix_name}-${resource.random_string.random.result}-${count.index}"
  count            = local.vm_instance_count
  num_cpus         = var.vm_cpu
  memory           = var.vm_memory

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  
  # https://github.com/hashicorp/terraform-provider-vsphere/issues/1496
  # efi or bios -- datasource content_library_item does not have firmware type
  # if running ESXi 7.0.1 or lower (fixed on 7.0.2)
  firmware = "efi"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = var.vm_disk0_size
  }
  
  clone {
    template_uuid = "${data.vsphere_content_library_item.library_item.id}"
   }

  # If not using cloud-image you can use extra_configs (crashes on ubuntu because of vapp)
  # only works with cloud-init 21.3+ on vsphere (double check cloud-init guest OS version)  
  extra_config = {
    "guestinfo.metadata" = base64encode(
                                        templatefile("cloud-init/cloud-init-metadata.tpl",
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
                                        templatefile("cloud-init/cloud-init-userdata.tpl", 
                                          { 
                                            ssh_public_key = file(var.ssh_public_key),
                                            root_password = var.vm_root_password
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
    host      = "${self.default_ip_address}"
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
    }
  }

}
