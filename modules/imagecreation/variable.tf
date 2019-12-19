variable "resourcegroup_name" {
  description = "The name of resource group"
  default = "terraformrg"
}
variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "southeastasia"
}

variable "managed_image_name" {
    description = "The name of managed image to be created."
    default = "imgtestwithdatadisk"
}
variable "os_managed_disk_id" {
    description = "The id of os managed image to created from Packer Azure-chroot."
}
variable "data_managed_disk_id" {
    description = "The id of data managed image to created from Packer Azure-chroot."
}

variable "provisioner_id" {
    description = "provisioner id from previous module."
}