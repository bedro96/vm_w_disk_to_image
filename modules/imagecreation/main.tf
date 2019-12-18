# Create a resource group if it doesn’t exist
data "azurerm_resource_group" "terraformrg" {
  name = "${var.resourcegroup_name}"
}

# resource "azurerm_resource_group" "terraformrg" {
#     name     = "${var.resourcegroup_name}"
#     location = "${var.location}"

#     tags = {
#         environment = "Terraform Deployment"
#     }
# }

# resource "azurerm_snapshot" "ossnapshot" {
#   name                = "ubuntu1604-osdisk-snapshot"
#   location            = "${data.azurerm_resource_group.terraformrg.location}"
#   resource_group_name = "${data.azurerm_resource_group.terraformrg.name}"
#   create_option       = "Copy"
#   source_uri          = "${var.os_managed_disk_id}"
# }

# resource "azurerm_snapshot" "datasnapshot" {
#   name                = "ubuntu1604-datadisk-snapshot"
#   location            = "${data.azurerm_resource_group.terraformrg.location}"
#   resource_group_name = "${data.azurerm_resource_group.terraformrg.name}"
#   create_option       = "Copy"
#   source_uri          = "${var.data_managed_disk_id}"
# }

resource "azurerm_image" "packer-img-w-datadisk" {
    name                = "${var.managed_image_name}"
    location            = "${data.azurerm_resource_group.terraformrg.location}"
    resource_group_name = "${data.azurerm_resource_group.terraformrg.name}"

    os_disk {
        os_type  = "Linux"
        os_state = "Generalized"
        managed_disk_id = "${var.os_managed_disk_id}"
        size_gb  = 50
    }

    data_disk {
        lun = 0
        caching = "ReadWrite"
        managed_disk_id = "${var.data_managed_disk_id}"
        size_gb = 250
    }
}
