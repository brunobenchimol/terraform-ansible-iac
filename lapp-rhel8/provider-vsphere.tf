# Configure the VMware vSphere Provider
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # if you have a self-signed cert
  allow_unverified_ssl = true
}

# vSphere Data Sources
data "vsphere_datacenter" "dc" {
  name = var.vsphere_dcname
}
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name          =  var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network_lb" {
  name          =  (var.vsphere_network_lb != "") ? var.vsphere_network_lb : var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "pool" {
  name          = "${data.vsphere_compute_cluster.cluster.name}/${var.vsphere_resoucepool}" 
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_content_library" "library" {
  name = var.vsphere_library_name
}
data "vsphere_content_library_item" "library_item" {
  name       = var.vsphere_library_item
  library_id = data.vsphere_content_library.library.id
  type       = var.vsphere_library_item_type
}