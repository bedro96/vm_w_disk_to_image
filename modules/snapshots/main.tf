# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "terraformrg" {
    name     = "${var.resourcegroup_name}"
    location = "${var.location}"

    tags = {
        environment = "Terraform Deployment"
    }
}

resource "azurerm_snapshot" "ossnapshot" {
  name                = "ubuntu1604-osdisk-snapshot"
  location            = "${azurerm_resource_group.terraformrg.location}"
  resource_group_name = "${azurerm_resource_group.terraformrg.name}"
  create_option       = "Copy"
  source_uri          = "module.ubuntuvm.os_managed_disk_id"
}

resource "azurerm_snapshot" "datasnapshot" {
  name                = "ubuntu1604-datadisk-snapshot"
  location            = "${azurerm_resource_group.terraformrg.location}"
  resource_group_name = "${azurerm_resource_group.terraformrg.name}"
  create_option       = "Copy"
  source_uri          = "module.ubuntuvm.data_managed_disk_id"
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