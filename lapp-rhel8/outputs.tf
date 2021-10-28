output "random-id" {
    value = random_string.random.result
    description = "Random ID (string) to append to name"
}

output "vm_ip_address" {
  value = "${formatlist(
    "%s = %s", 
    (vsphere_virtual_machine.vm-lapp.*.name),
    (vsphere_virtual_machine.vm-lapp.*.default_ip_address)
  )}"

  description = "Network IP address from Virtual Machines"
}