# Configure the Nutanix Provider
provider "nutanix" {
  username        = var.prism_user
  password        = var.prism_password
  endpoint        = var.prism_server

  # if you have a self-signed cert
  insecure        = true
  wait_timeout    = 60
}

# Nutanix Data Sources
data "nutanix_cluster" "cluster" {
  name = var.prism_cluster
}
data "nutanix_subnet" "subnet" {
  subnet_name = var.prism_subnet
}

# Either choose image or upload with resource
data "nutanix_image" "image" {
  image_name = var.prism_image_name
}

/* 
# Upload Template to AHV Image Service 
resource "nutanix_image" "ubuntu_image" {
  name        = "ubuntu-20.04-server-cloudimg-amd64"
  description = "Ubuntu 20.04 Server Cloud Image"
  source_uri  = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
  # optional
  #image_type = "ova"
}

resource "nutanix_image" "centos8_image" {
  name        = "CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64"
  description = "CentOS 8.4 Generic Cloud Image"
  source_uri  = "https://cloud.centos.org/centos/8/x86_64/images/#:~:text=CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
  # optional
  #image_type = "ova"
}
*/