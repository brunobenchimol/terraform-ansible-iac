# lapp-rhel8

**LAPP** (Linux, Apache, PostgreSQL, PHP) on RHEL 8 on vSphere with Terraform + Ansible + Cloud-Init

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
| `ansible/vars.yml` | Ansible Variables File |


# Preparing RHEL 8 Template

 You must install [cloud-init-vmware-guestinfo](https://github.com/vmware-archive/cloud-init-vmware-guestinfo) until Red Hat updates cloud-init to 21.3+.     
 There is a simple script on [scripts/rhel-prep-template.sh](https://github.com/brunobenchimol/terraform-ansible-iac/blob/main/lapp-rhel8/scripts/rhel-prep-template.sh) that help on this process. Other steps on the script are to cleanup the installation to better suit needs to provision/clone multiple VMs.  
 Its built on top of my previous project: [vsphere-rhel8-cloudinit](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/vsphere-rhel8-cloudinit). So same Notes/Caveats Apply.  

**This step is mandatory and must be done outside of Terraform**

# TODO

1. Certbot / Lets Encrypt / ACME  

# Notes / Caveats

1. **Built on top of vsphere-rhel8-cloudinit project**  
Since its built on top of project [vsphere-rhel8-cloudinit](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/vsphere-rhel8-cloudinit), it has the same [Notes/Caveats](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/vsphere-rhel8-cloudinit#notes--caveats).   

2. **Only 1 VM, Not Scable**   
Its only an example how to deploy a LAPP (opposed to [LAMP](https://en.wikipedia.org/wiki/LAMP_(software_bundle)). If you want a full-fledged installation check out my other implementation of [3 Tier Application](https://github.com/brunobenchimol/terraform-ansible-iac/tree/main/3-tier-lb-web-db-application) (Multiple Web Servers, High Availability LoadBalancer and Database).   

3. **Is it only for RHEL ?**    
Most of my IaC on RHEL systems. I could develop some on Debian aswell, but we running RHEL (Rocky Linux soon) since everyone has 16 "free" systems registered. Because of that Ansible Playbooks are mostly running only on RHEL and not Debian flavour distros.   

4. **Unregistering from RHN/Satellite only works when using default ssh key location \(~/.ssh/id_rsa\*\)**    
*Destroy-time provisioners and their connection configurations may only reference attributes of the related resource, via 'self', 'count.index', or 'each.key'.*   
Cant see to find a way to pass ssh key location on a variable using self or any of these *reference attributes*.   
`Dirty Fix`: Created a resource to generate "local_file" ansible.cfg in the current directly with private_key_file. Not pretty but does the job. May break if you have/need a custom ansible.cfg in-place.
**HELP WANTED** to fix/discuss this issue.  

5. **Ansible/Database Configuration**    
Edit `ansible/vars.yml` to set parameters (*variables*) for you database. We do not have many to set yet.   
**Question:** Use vars.yml or Use enviroment and pass it using Terraform enviroment and lookup (!?)      


# References

1. https://github.com/brunobenchimol/terraform-ansible-cicd/tree/main/vsphere-rhel8-cloudinit
2. https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html
3. https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#using-roles
4. https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html
5. https://docs.ansible.com/ansible/latest/galaxy/user_guide.html
6. https://galaxy.ansible.com/community/postgresql
7. https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html
8. https://www.postgresql.org/download/linux/redhat
9. https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html
10. https://www.redhat.com/files/summit/session-assets/2019/T97171.pdf  
11. https://docs.ansible.com/ansible/latest/collections/ansible/builtin/dnf_module.html
11. https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html
