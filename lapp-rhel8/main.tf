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
  metadata_tpl_file = "${path.module}/templates/cloud-init-metadata.tpl"
  userdata_tpl_file = "${path.module}/templates/cloud-init-userdata.tpl"
  vm_instance_count = (local.is_dhcp_enabled ? var.vm_count : length(var.vm_ipaddress_list))
  is_dhcp_enabled   = (var.vm_ipaddress_list != tolist([]) ? false : true)
  is_rhn_enabled_cloudinit    = (var.rhn_username != "" && var.force_rhn_enable_cloud_init == "true" ? true : false)
  is_rhn_enabled_ansible      = (var.rhn_username != "" && var.force_rhn_enable_cloud_init == "false" ? true : false)
  vm_prefix_name              = "${var.app_prefix_name}-${terraform.workspace}-${resource.random_string.random.result}"
}

resource "vsphere_virtual_machine" "vm-lapp" {
  name             = "${local.vm_prefix_name}-lapp-${count.index}"
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
    size  = var.vm_root_disk_size
  }
  
  disk {
    label = "database_disk"
    size  =  var.app_database_disk_size
    thin_provisioned = true
    unit_number = 1
  }


  clone {
    template_uuid = "${data.vsphere_content_library_item.library_item.id}"
   }

  # You must follow the rhel template preparation
  # only works with cloud-init 21.3+ on vsphere (double check cloud-init guest OS version)  
  extra_config = {
    "guestinfo.metadata" = base64encode(
                                        templatefile(local.metadata_tpl_file,
                                          {
                                            hostname    = "${local.vm_prefix_name}-lapp-${count.index}",
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
                                            root_password = var.vm_root_password,
                                            rhn = local.is_rhn_enabled_cloudinit,
                                            rhn_username = var.rhn_username,
                                            rhn_password = var.rhn_password
                                          }
                                        )
                                      )
    "guestinfo.userdata.encoding" = "base64"
  }

  # Make sure host is up and running to run ansible-playbook
  provisioner "remote-exec" {
    # SSH connection config
    connection {
      type     = "ssh" # default
      port     = "22" # default
      user     = "root" # default
      host      = "${self.default_ip_address}"
      private_key = file(var.ssh_private_key)
    }

    inline = [ "uptime" ]
  }

  # Make sure ansible galaxy collections requirements are installed
  provisioner "local-exec" {
    command = "ansible-galaxy collection install -r ${path.module}/ansible/requirements.yml"
  }

  # Run commands on local host (start ansible from within terraform)
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.default_ip_address}, --user root --private-key ${var.ssh_private_key} ${path.module}/ansible/main.yml"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ENABLE_RHN = local.is_rhn_enabled_ansible
      RHN_USERNAME = var.rhn_username
      RHN_PASSWORD = var.rhn_password
      UPGRADE_PACKAGES = "True"
    }
  }

  # unregister machine from RHN/Satellite when destroying
  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue

    # CAVEAT: CANT USE SSH KEY OUTSIDE DEFAULT LOCATION -- cant get variable on self
    # Destroy-time provisioners and their connection configurations may only reference attributes of the related resource, via 'self', 'count.index', or 'each.key'.
    #command = "ansible -i ${self.default_ip_address}, all --user root --private-key ${var.ssh_private_key} -m redhat_subscription  -a \"state=absent\""
    # Quick Fix: Create ansible.cfg in the root directory
    command = "ansible -i ${self.default_ip_address}, all --user root -m redhat_subscription  -a \"state=absent\""
  }
 
}

resource "local_file" "ansible_config" {
  count = (var.ssh_private_key != "~/.ssh/id_rsa" ? 1 : 0 )
  filename = "${path.root}/ansible.cfg"
  file_permission = 0640

  content = <<-EOF
    [defaults]
    private_key_file = ${var.ssh_private_key}
  EOF

}