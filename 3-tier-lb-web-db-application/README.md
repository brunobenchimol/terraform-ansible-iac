# 3-tier-lb-web-db-application

**3 Tier Application** (HA Load Balancers, Multiple Web Servers and Database) on RHEL 8 on vSphere with Terraform + Ansible + Cloud-Init


*Main Purpose*: Show how Terraform can integrate with Ansible to perform complex / multi VM orchestration.


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
| `templates/*` | Cloud-Init & Jinja Templates files in use |
| `scripts/*` | Scripts for preparing RHEL Template | 
| `ansible/*` | Ansible Playbook with Roles |
| `ansible/requirements.yml` | Ansible Galaxy Requirements file |
| `ansible/vars.yml` | Ansible Variables File |


# Preparing RHEL 8 Template

 You must install [cloud-init-vmware-guestinfo](https://github.com/vmware-archive/cloud-init-vmware-guestinfo) until Red Hat updates cloud-init to 21.3+.     
 There is a simple script on [scripts/rhel-prep-template.sh](https://github.com/brunobenchimol/terraform-ansible-iac/blob/main/vsphere-rhel8-cloudinit/scripts/rhel-prep-template.sh) that help on this process. Other steps on the script are to cleanup the installation to better suit needs to provision/clone multiple VMs.  
 Its built on top of my previous project: [vsphere-rhel8-cloudinit](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/vsphere-rhel8-cloudinit). So same Notes/Caveats Apply.  

**This is step is mandatory and must be done outside of Terraform**

# TODO

1. Certbot on HAPROXY
2. Copy SSL Certificate between hosts (with a cronjob) - Try [synchronize_module](https://docs.ansible.com/ansible/2.9/modules/synchronize_module.html) ??  
3. Central Logging - Syslog (???)
10. Still thinking ...


# Notes / Caveats

1. **Built on top of vsphere-rhel8-cloudinit project**  
Since its built on top of project [vsphere-rhel8-cloudinit](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/vsphere-rhel8-cloudinit) and [lapp-rhel8](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/lapp-rhel8) it has the same Notes/Caveats [1](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/vsphere-rhel8-cloudinit#notes--caveats)[2](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/lapp-rhel8#notes--caveats).    

2. **Why 2 ansible "main" files and provisioners**   
Ansible and Terraform overlap on many areas. Because of that we decided to stick with Terraform for provisioning and Ansible for configuration.   
On `ansible` directory, we use *main.yml* to with configure hosts when are provisioning (mininal configurations) and *main-lapp-config.yml* to configure hosts after they are already up (the configuration itself). We are using Terraform to generate automatically `ansible inventory` and it can only do it after everything is provisioned.    
Another way is to provisioning and apply configuration after they are up, but we decided to show another way (*unusual*) to control ansible playbook execution without using `ansible inventory`.   
The main purpose is also to be able to run those ansible playbooks to control configuration of the infrastructure aswell leveraging as much as we can from IaC (makes it much easier to use on a future CI/CD pipeline).   

3. **100% DHCP or 100% STATIC - Not allowed to mix**      
If you set static ip address for web VM everything will have static IP. Thats how its on the code. Either it will be 100% DHCP or 100% STATIC.   

4. **Load Balancer may be on a different network**    
Set `vsphere_network_lb != vsphere_network` and it use different network configuration. It `defaults` to same as other VMs (web/database).    

5. **Must set env to run change configuration on KEEPALIVED when running ansible outside Terraform**   
Should feed somewhere this information to keep track of configuration and make better use of IaC.    


# References

1. https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/vsphere-rhel8-cloudinit
2. https://www.percona.com/blog/2021/06/01/how-to-generate-an-ansible-inventory-with-terraform
3. https://www.linkbynet.com/en/news/produce-an-ansible-inventory-with-terraform
4. https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html
5. https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#using-roles
6. https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html
7. https://docs.ansible.com/ansible/latest/galaxy/user_guide.html
8. https://galaxy.ansible.com/community/postgresql
9. https://galaxy.ansible.com/evrardjp/keepalived
10. https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html#information-about-ansible-magic-variables
11. https://learn.redhat.com/t5/Automation-Management-Ansible/Ansible-hostvars-with-jinja2-template/td-p/14957
12. https://stackoverflow.com/questions/26989492/ansible-loop-through-group-vars-in-template
13. https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html
14. https://regex101.com/
15. https://www.haproxy.com/blog/introduction-to-haproxy-logging/
16. https://docs.ansible.com/ansible/2.9/modules/openssl_certificate_module.html
17. https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html
18. https://docs.ansible.com/ansible/latest/user_guide/playbooks_templating.html