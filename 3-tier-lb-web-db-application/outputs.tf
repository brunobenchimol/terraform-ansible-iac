 output "web_vm_ip_address" {
  value = formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.vm-web[*].name),
    (vsphere_virtual_machine.vm-web[*].default_ip_address)
  )

  description = "Network IP address from Web VMs"
}

output "db_vm_ip_address" {
  value = formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.vm-database[*].name),
    (vsphere_virtual_machine.vm-database[*].default_ip_address)
  )

  description = "Network IP address from Database VMs"
}

output "lb_vm_ip_address" {
  value = formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.vm-loadbalancer[*].name),
    (vsphere_virtual_machine.vm-loadbalancer[*].default_ip_address)
  )
  
  description = "Network IP address from Load Balance VMs"
}

output "ansible_inventory_output" {
  value = templatefile("${path.module}/templates/ansible_inventory.tmpl", 
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
