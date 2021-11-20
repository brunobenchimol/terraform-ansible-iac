# nutanix-centos8-cloudinit

CentOS 8 on Nutanix + Terraform + Ansible + Cloud-Init

*Main Purpose*: Bringing some cloud-like automation to on-premise installations with CentOS and Nutanix 


# Usage

1. `terraform init`
2. `terraform plan`
3. `terraform apply` 


# Enviroment Tested

Prism Central pc.2021.9  
AOS 5.20 LTS   
CentOS 8.4   


# Important Files 

| File / Directory | Description |
| ---------- | ----------- |
| `terraform.tfvars`      |  Variables Definitions File | 
| `variables.tf`  |  Input Variables to help with terraform.tfvars |
| `cloud-init/*.tpl` | Cloud-Init Templates files in use |


# Notes / Caveats

1. **Cloud-Init**  
Most of these files are placeholder examples. You should change to suit your needs.  
[Cloud-Init Examples](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)  

2. **Nutanix Provider has issues with Cloud-Init**   
Provider is failing to create proper metadata config, but works fine with user-data. That leads to some tweaks to get it working. If you want to see more check out [GitHub Issue #303](https://github.com/nutanix/terraform-provider-nutanix/issues/303)  

3. **Nutanix Provider has issue with 'boot_type' LEGACY**    
Follow/Watch discussion on [GitHub Issue#304](https://github.com/nutanix/terraform-provider-nutanix/issues/304)    
`Quick Fix`: Comment `boot_type` if you have BIOS installation. If using EFI set to `UEFI`.  

4. **Nutanix Provider does not support OVA images, you must use Disk Images**
Prism Element does not support OVA at present moment, only Prism Central. Nutanix Provider does not support OVA when configuring `nutanix_image`.   


# References

1. https://github.com/nutanixdev/terraform_blog  
2. https://www.nutanix.dev/2021/04/20/using-the-nutanix-terraform-provider/  
3. https://portal.nutanix.com/page/documents/details?targetId=Prism-Central-Guide-Prism-v6_0:mul-images-upload-from-vm-disk-pc-t.html  
4. https://registry.terraform.io/providers/nutanix/nutanix/latest/docs/resources/virtual_machine 
5. https://www.lets-talk-about.tech/2020/01/nutanix-create-simple-vm-with-terraform.html 
6. https://www.nutanix.dev/2021/04/20/using-the-nutanix-terraform-provider/   
7. https://github.com/izecevic/terraform/blob/master/nutanix/ntnx-vms/main.tf  
8. https://next.nutanix.com/nug-switzerland-chapter-106/nutanix-iac-using-hashicorp-terraform-39317   
