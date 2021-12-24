# vsphere-centos8-cloudinit

CentOS 8 on vSphere + Terraform +  Cloud-Init

*Main Purpose*: Bringing some cloud-like automation to on-premise installations with CentOS and Nutanix 


# Usage

1. `terraform init`
2. `terraform plan`
3. `terraform apply` 


# Enviroment Tested

vSphere 7   
CentOS 8.5    

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

2. **CentOS 8.5 Cloud-init version is outdated**   
We need [cloud-init-vmware-guestinfo](c) deprecated plugin becase of CentOS 8.5 provides cloud-init version 21.1 and we need a newer version 21.3 to read extra_config (VMX Advanced Options). You must install yourself the VMware GuestInfo *datasource* from vmware archive cloud-init.   


# References

1. https://github.com/vmware-archive/cloud-init-vmware-guestinfo 
