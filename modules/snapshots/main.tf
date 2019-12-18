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

resource "azurerm_snapshot" "ossnapshot" {
  name                = "ubuntu1604-osdisk-snapshot"
  location            = "${data.azurerm_resource_group.terraformrg.location}"
  resource_group_name = "${data.azurerm_resource_group.terraformrg.name}"
  create_option       = "Copy"
  source_uri          = "${var.os_source_uri}"
}

resource "azurerm_snapshot" "datasnapshot" {
  name                = "ubuntu1604-datadisk-snapshot"
  location            = "${data.azurerm_resource_group.terraformrg.location}"
  resource_group_name = "${data.azurerm_resource_group.terraformrg.name}"
  create_option       = "Copy"
  source_uri          = "${var.data_source_uri}"
}

# resource "azurerm_shared_image_gallery" "terraformgallery" {
#   name                = "terraformgallery"
#   location            = "${azurerm_resource_group.terraformrg.location}"
#   resource_group_name = "${azurerm_resource_group.terraformrg.name}"
#   description         = "Shared images and things."
# }

# resource "azurerm_shared_image" "specialized-image" {
#   name                = "specialized-image"
#   gallery_name        = "${azurerm_shared_image_gallery.kukoImage2.name}"
#   location            = "${azurerm_resource_group.terraformrg.location}"
#   resource_group_name = "${azurerm_resource_group.terraformrg.name}"
#   os_type             = "Linux"
#   osState             = "Specialized"

#   identifier {
#     publisher = "PublisherName"
#     offer     = "OfferName"
#     sku       = "ExampleSku"
#   }
# }