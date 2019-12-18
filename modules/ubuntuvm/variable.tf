variable "resourcegroup_name" {
  description = "The name of resource group"
  default = "terraformrg"
}
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default = "terraformvmss"
}
variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "southeastasia"
}
variable "ssh_username" {
  description = "ssh username."
}
variable "ssh_port" {
  description = "ssh Port."
  default = "22"
}
variable "ssh_password" {
  description = "ssh password."
}
variable "vm_size" {
  description = "The vm SKU"
  default = "Standard_B2ms"
}
variable "image_id" {
  description = "id of generalized manged image"
}