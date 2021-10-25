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
| `cloud-init/*.tpl` | Cloud-Init Templates files in use |
| `scripts/*` | Scripts for preparing RHEL Template | 
| `ansible-playbook.yml` | Ansible Playbook placeholder |


# Preparing RHEL 8 Template

 You must install [cloud-init-vmware-guestinfo](https://github.com/vmware-archive/cloud-init-vmware-guestinfo) until Red Hat updates cloud-init to 21.3+.     
 There is a simple script on [scripts/rhel-prep-template.sh] that help on this process. Other steps on the script are to cleanup the installation to better suit needs to provision/clone multiple VMs.  


# Notes / Caveats

1. **Cloud-Init and Ansible Files**  
Most of these files are placeholder examples. You should change to suit your needs.  
[Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)  
[Ansible User Guide](https://docs.ansible.com/ansible/latest/user_guide/index.html)  

2. **RHEL 8.4 Cloud-init version is outdated** 
We need [cloud-init-vmware-guestinfo](https://github.com/vmware-archive/cloud-init-vmware-guestinfo) deprecated plugin becase of RHEL 8.4 provides cloud-init version 20.3 and we need a newer version 21.3 to read extra_config (VMX Advanced Options). You must execute "template preperation before" running Terraform  

3. **vSphere Provider and Content Library Item does not have a firmware type**
Follow/Watch discussion on [GitHub Issue#1496](https://github.com/hashicorp/terraform-provider-vsphere/issues/1496)  
`Quick Fix`: Set firmware to 'efi' or 'bios' depending on your template/installation. Default is 'bios'.  

4. **RHN Register Support Cloud-Init**
It will expose your RHN credentials in clear-text. We favor using ansible to subscribe to RHN as its easier to protect/not expose your password. Because of that we must have python installed on VM template. `Default` to *ansible*.  
Set Terraform Variable `force_rhn_enable_cloud_init` to **true** if you want to use cloud-init userdata instead of ansible.  


# References

1. https://www.infralovers.com/en/articles/2021/01/21/vmware-templates-with-terraform-and-cloud-init/  
2. https://grantorchard.com/terraform-vsphere-cloud-init/  
3. https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment/  
4. https://blah.cloud/infrastructure/using-cloud-init-for-vm-templating-on-vsphere/  
5. https://access.redhat.com/blogs/1169563/posts/3640721  
6. https://access.redhat.com/solutions/2609081   
7. https://cloudinit.readthedocs.io/en/latest/topics/modules.html#red-hat-subscription  
8. https://docs.ansible.com/ansible/2.9/plugins/lookup/env.html   
9. https://www.mydailytutorials.com/working-with-environment%E2%80%8B-variables-in-ansible/   
