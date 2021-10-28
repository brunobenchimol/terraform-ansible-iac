# 3-tier-lb-web-db-application

**3 Tier Application** (HA Load Balancers, Multiple Web Servers and Database) on RHEL 8 on vSphere with Terraform + Ansible + Cloud-Init


*Main Purpose*: Bringing some cloud-like automation to on-premise installations with RHEL and VMware vSphere 


# Usage

0. *Template Preparation*
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
| `variables.tf`  |  Defined Input Variables  |
| `templates/*.tpl` | Cloud-Init Templates files in use |
| `scripts/*` | Scripts for preparing RHEL Template | 
| `ansible/*` | Ansible Playbook with Roles |
| `ansible/requirements.yml` | Ansible Galaxy Requirements file |


# Preparing RHEL 8 Template

 You must install [cloud-init-vmware-guestinfo](https://github.com/vmware-archive/cloud-init-vmware-guestinfo) until Red Hat updates cloud-init to 21.3+.     
 There is a simple script on [scripts/rhel-prep-template.sh](https://github.com/brunobenchimol/terraform-ansible-cicd/blob/main/vsphere-rhel8-cloudinit/scripts/rhel-prep-template.sh) that help on this process. Other steps on the script are to cleanup the installation to better suit needs to provision/clone multiple VMs.  
 Its built on top of my previous project: [vsphere-rhel8-cloudinit](https://github.com/brunobenchimol/terraform-ansible-cicd/tree/main/vsphere-rhel8-cloudinit). So same Notes/Caveats Apply.  

**This is step is mandatory and must be done outside of Terraform**

# TODO
PLACEHOLDER   

# Notes / Caveats

1. **Built on top of vsphere-rhel8-cloudinit project**  
Since its built on top of project [vsphere-rhel8-cloudinit](https://github.com/brunobenchimol/terraform-ansible-cicd/tree/main/, it has the same [Notes/Caveats](https://github.com/brunobenchimol/terraform-ansible-cicd/tree/main/vsphere-rhel8-cloudinit#notes--caveats).  PLACEHOLDER 

2. **Why 2 ansible "main" files and provisioners**   
Ansible and Terraform overlap on many areas. Because of that we decided to stick with Terraform for provisioning and Ansible for configuration.   
On `ansible` directory, we use *main.yml* to with configure hosts when are provisioning (mininal configurations) and *main-lapp-config.yml* to configure hosts after they are already up (the configuration itself). We are using Terraform to generate automatically `ansible inventory` and it can only do it after everything is provisioned.    
Another way is to provisioning and apply configuration after they are up, but we decided to show another way (*unusual*) to control ansible playbook execution without using `ansible inventory`.   
The main purpose is also to be able to run those ansible playbooks to control configuration of the infrastructure aswell leveraging as much as we can from IaC (makes it much easier to use on a future CI/CD pipeline).   

3. **Why Separate VMs for a LAPP instead a single box**    
From a security and infrastrucutre perspective it's better to keep as mininal surfaces.... PLACEHOLDER

4. **xxxxxxxxx**    
It will expose your RHN credentials in clear-text. We favor using ansible to subscribe to RHN as its easier to protect/not expose your password. Because of that we must have python installed on VM template. `Default` to *ansible*.  
Set Terraform Variable `force_rhn_enable_cloud_init` to **true** if you want to use cloud-init userdata instead of ansible.  xxxx PLACEHOLDER


# References

1. https://github.com/brunobenchimol/terraform-ansible-cicd/tree/main/vsphere-rhel8-cloudinit
2. https://www.percona.com/blog/2021/06/01/how-to-generate-an-ansible-inventory-with-terraform
3. https://www.linkbynet.com/en/news/produce-an-ansible-inventory-with-terraform
4. https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html
5. https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#using-roles
6. https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html
7. https://docs.ansible.com/ansible/latest/galaxy/user_guide.html
8. https://galaxy.ansible.com/community/postgresql
PLACEHOLDER   
