# vsphere-ubuntu20-cloudinit


Ubuntu 20 on vSphere + Terraform + Ansible + Cloud-Init

*Main Purpose*: Bringing some cloud-like automation to on-premise installations with Ubuntu Linux and VMware vSphere. 

# Usage

1. `terraform init`
2. `terraform plan`
3. `terraform apply` 

# Enviroment Tested

vSphere 7  
Ubuntu 20.04 LTS

# Important Files 

| File / Directory | Description |
| ---------- | ----------- |
| `terraform.tfvars`      |  Variables Definitions File | 
| `variables.tf`  |  Input Variables to help with terraform.tfvars |
| `cloud-init/*` | Cloud-Init Templates files in use | 

# Notes / Caveats

1. **Cloud-Init and Ansible Files**  
Most of these files are placeholder examples. You should change to suit your needs.  
[Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)  
[Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/index.html)  

2. **Error: this virtual machine requires a client CDROM device to deliver vApp properties**   
Having issues when destroying Ubuntu Cloud Images complains about needing a cdrom (if we use cdrom it fails customization), but it does work destroy when changing decreasing number of instances. There are multiple ways to fix it.   
`vSphere Fix`: Disable vApp Options on vSphere Template  
`Terraform Fix`: Add cdrom {} and vapp {} on vsphere_virtual_machine {} and revert configs to cloud-init versions early than 21.3  
`Ubuntu Fix`: Change datasource order list to read "VMware" before "OVF"   

# References

1. https://www.infralovers.com/en/articles/2021/01/21/vmware-templates-with-terraform-and-cloud-init/
2. https://grantorchard.com/terraform-vsphere-cloud-init/   
3. https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment/  
4. https://blah.cloud/infrastructure/using-cloud-init-for-vm-templating-on-vsphere/   
