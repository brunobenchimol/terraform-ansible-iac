# vsphere-rhel8-cloudinit

RHEL 8 on vSphere + Terraform + Ansible + Cloud-Init

*Main Purpose*: Bringing some cloud-like automation to on-premise installations with RHEL and VMware vSphere 

# Usage

1. `terraform init`
2. `terraform plan`
3. `terraform apply` 

# Enviroment Tested

vSphere 7
RHEL 8.4

# Important Files 

| File / Directory | Description |
| ---------- | ----------- |
| `terraform.tfvars`      |  Variables Definitions File | 
| `variables.tf`  |  Input Variables to help with terraform.tfvars |
| `cloud-init/*` | Cloud-Init Templates files in use |
| `scripts/*` | Scripts for preparing RHEL Template | 

# Preparing RHEL 8 Template

 You must install [cloud-init-vmware-guestinfo](https://github.com/vmware-archive/cloud-init-vmware-guestinfo) until Red Hat updates cloud-init to 21.3+.     
 Other steps on the script is to cleanup the installation to better suit needs to provision/clone multiple VMs.  

# Notes / Caveats

1. **Cloud-Init and Ansible Files**  
Most of these files are placeholder examples. You should change to suit your needs.  
[Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)  
[Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/index.html)  

2. **RHEL 8.4 Cloud-init version is old** 
We need [cloud-init-vmware-guestinfo](https://github.com/vmware-archive/cloud-init-vmware-guestinfo) deprecated plugin becase of RHEL 8.4 provides cloud-init version 20.3 and we need a newer version 21.3 to read extra_config (VMX Advanced Options). You must execute "template preperation before" running Terraform  

# References

1. https://www.infralovers.com/en/articles/2021/01/21/vmware-templates-with-terraform-and-cloud-init/  
2. https://grantorchard.com/terraform-vsphere-cloud-init/  
3. https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment/  
4. https://blah.cloud/infrastructure/using-cloud-init-for-vm-templating-on-vsphere/  
5. https://access.redhat.com/blogs/1169563/posts/3640721  
