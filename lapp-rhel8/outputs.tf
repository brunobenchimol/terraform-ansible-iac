output "vm_ip_address" {
  value = formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.vm-lapp.*.name),
    (vsphere_virtual_machine.vm-lapp.*.default_ip_address)
  )

  description = "Network IP address from Virtual Machines"
}