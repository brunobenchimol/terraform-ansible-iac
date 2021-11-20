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
  vm_web_instance_count = (local.is_dhcp_enabled ? var.vm_web_count : length(var.vm_web_ipaddress_list))
  vm_lb_instance_count = (local.is_dhcp_enabled ? 2 : length(var.vm_lb_ipaddress_list) )
  is_dhcp_enabled   = (var.vm_web_ipaddress_list != tolist([]) ? false : true)
  is_rhn_enabled_cloudinit    = (var.rhn_username != "" && var.force_rhn_enable_cloud_init == "true" ? true : false)
  is_rhn_enabled_ansible      = (var.rhn_username != "" && var.force_rhn_enable_cloud_init == "false" ? true : false)
  vm_prefix_name              = "${var.app_prefix_name}-${terraform.workspace}-${resource.random_string.random.result}"
  vm_lb_dns_servers = (var.vm_lb_dns_servers != tolist([]) ? var.vm_lb_dns_servers : var.vm_dns_servers)
  vm_lb_domain = (var.vm_lb_domain != tolist([]) ? var.vm_lb_domain : var.vm_domain)
  vm_lb_gateway = (var.vm_lb_gateway != "" ? var.vm_lb_gateway : var.vm_gateway)
  vm_lb_ipnetmask = (var.vm_lb_ipnetmask != "" ? var.vm_lb_ipnetmask : var.vm_ipnetmask)
}

resource "vsphere_virtual_machine" "vm-web" {
  name             = "${local.vm_prefix_name}-web-${count.index}"
  count            = var.app_high_availbility ? local.vm_web_instance_count : 1

  num_cpus         = var.vm_web_cpu
  memory           = var.vm_web_memory

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
  
  clone {
    template_uuid = data.vsphere_content_library_item.library_item.id
   }

  # You must follow the rhel template preparation
  # only works with cloud-init 21.3+ on vsphere (double check cloud-init guest OS version)  
  extra_config = {
    "guestinfo.metadata" = base64encode(
                                        templatefile(local.metadata_tpl_file,
                                          {
                                            hostname    = "${local.vm_prefix_name}-web-${count.index}",
                                            dhcp        = local.is_dhcp_enabled,
                                            ip_address  = try(element(var.vm_web_ipaddress_list, count.index), ""),
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
      host      = self.default_ip_address
      private_key = file(var.ssh_private_key)
    }

    inline = [ "uptime" ]
  }

  # Run commands on local host (start ansible from within terraform)
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.default_ip_address}, --user root --private-key ${var.ssh_private_key} ${path.module}/ansible/main.yml"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ENABLE_RHN = local.is_rhn_enabled_ansible
      RHN_USERNAME = var.rhn_username
      RHN_PASSWORD = var.rhn_password
    }
  }

  # unregister machine from RHN/Satellite when destroying
  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue

    command = "ansible -i ${self.default_ip_address}, all --user root -m redhat_subscription  -a \"state=absent\""

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

}

resource "vsphere_virtual_machine" "vm-database" {
  name             = "${local.vm_prefix_name}-db-${count.index}"
  count            = 1

  num_cpus         = var.vm_db_cpu
  memory           = var.vm_db_memory

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
    template_uuid = data.vsphere_content_library_item.library_item.id
   }

  # You must follow the rhel template preparation
  # only works with cloud-init 21.3+ on vsphere (double check cloud-init guest OS version)  
  extra_config = {
    "guestinfo.metadata" = base64encode(
                                        templatefile(local.metadata_tpl_file,
                                          {
                                            hostname    = "${local.vm_prefix_name}-db-${count.index}",
                                            dhcp        = local.is_dhcp_enabled,
                                            ip_address  = try(element(var.vm_db_ipaddress_list, count.index), ""),
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
      host      = self.default_ip_address
      private_key = file(var.ssh_private_key)
    }

    inline = [ "uptime" ]
  }

  # Run commands on local host (start ansible from within terraform)
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.default_ip_address}, --user root --private-key ${var.ssh_private_key} ${path.module}/ansible/main.yml"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ENABLE_RHN = local.is_rhn_enabled_ansible
      RHN_USERNAME = var.rhn_username
      RHN_PASSWORD = var.rhn_password
    }
  }

  # unregister machine from RHN/Satellite when destroying
  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue

    command = "ansible -i ${self.default_ip_address}, all --user root -m redhat_subscription  -a \"state=absent\""

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

}

resource "vsphere_virtual_machine" "vm-loadbalancer" {
  name             = "${local.vm_prefix_name}-lb-${count.index}"
  count            = var.app_high_availbility ? local.vm_lb_instance_count : 0


  num_cpus         = var.vm_lb_cpu
  memory           = var.vm_lb_memory

  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  
  # Until there is a change on how OVF are handled we must set it
  firmware = var.vm_firmware
  efi_secure_boot_enabled = var.vm_efi_secure_boot_enabled

  network_interface {
    network_id = data.vsphere_network.network_lb.id
  }

  disk {
    label = "disk0"
    size  = var.vm_root_disk_size
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
                                            hostname    = "${local.vm_prefix_name}-lb-${count.index}",
                                            dhcp        = local.is_dhcp_enabled,
                                            ip_address  = try(element(var.vm_lb_ipaddress_list, count.index), ""),
                                            netmask     = local.vm_lb_ipnetmask,
                                            domain      = jsonencode(local.vm_lb_domain),
                                            nameservers = jsonencode(local.vm_lb_dns_servers),
                                            gateway     = local.vm_lb_gateway
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
      host      = self.default_ip_address
      private_key = file(var.ssh_private_key)
    }

    inline = [ "uptime" ]
  }

  # Run commands on local host (start ansible from within terraform)
  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.default_ip_address}, --user root --private-key ${var.ssh_private_key} ${path.module}/ansible/main.yml"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ENABLE_RHN = local.is_rhn_enabled_ansible
      RHN_USERNAME = var.rhn_username
      RHN_PASSWORD = var.rhn_password
    }
  }

  # unregister machine from RHN/Satellite when destroying
  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue

    command = "ansible -i ${self.default_ip_address}, all --user root -m redhat_subscription  -a \"state=absent\""

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

}

resource "null_resource" "ansible_configure_post_install" {
  # Make sure ansible galaxy collections requirements are installed
  provisioner "local-exec" {
    command = "ansible-galaxy collection install -r ${path.module}/ansible/requirements.yml"
  }

  # Make sure ansible galaxy roles requirements are installed
  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${path.module}/ansible/requirements.yml"
  }

  # Run commands on local host (start ansible from within terraform)
  provisioner "local-exec" {
    command = "ansible-playbook -i ${resource.local_file.ansible_inventory.filename} --user root --private-key ${var.ssh_private_key} ${path.module}/ansible/main-app-config.yml"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
      ENABLE_KEEPALIVED = var.app_high_availbility
      KEEPALIVE_VIP = var.vm_lb_vip_ipaddress
      KEEPALIVE_PASSWORD = "${random_string.random.result}-pwd"
    }
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/ansible_inventory.ini"
  file_permission = "0640" 

  content = templatefile("${path.module}/templates/ansible_inventory.tmpl", 
              {  
                web_names           = vsphere_virtual_machine.vm-web[*].name,  
                web_ips             = vsphere_virtual_machine.vm-web[*].default_ip_address,  
                database_names      = vsphere_virtual_machine.vm-database[*].name,
                database_ips        = vsphere_virtual_machine.vm-database[*].default_ip_address, 
                loadbalancer_names  = vsphere_virtual_machine.vm-loadbalancer[*].name, 
                loadbalancer_ips    = vsphere_virtual_machine.vm-loadbalancer[*].default_ip_address
              } 
            )
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