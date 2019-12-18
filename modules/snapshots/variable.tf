variable "resourcegroup_name" {
  description = "The name of resource group"
  default = "terraformrg"
}
variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default = "southeastasia"
}
variable "os_source_uri" {
  description = "Source uri for os managed disk"
}
variable "data_source_uri" {
  description = "Source uri for data managed disk"
}