# Configure the Microsoft Azure Provider
data "azurerm_subscription" "current" {}
data "azurerm_subscription" "primary" {}
data "azurerm_subscription" "subscription" {}

# Generate random number
resource "random_integer" "ri" {
  min = 000
  max = 999
}

locals {
  # Ids for multiple vm.
  base_computer_name = "ubuntu1604${random_integer.ri.result}"
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "terraformrg" {
    name     = "${var.resourcegroup_name}"
    location = "${var.location}"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "terraformvnet" {
    name                = "terraformvnet"
    address_space       = ["10.100.0.0/16"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.terraformrg.name}"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Create subnet
resource "azurerm_subnet" "terraformvnetserversubnet" {
    name                 = "serversubnet"
    resource_group_name  = "${azurerm_resource_group.terraformrg.name}"
    virtual_network_name = "${azurerm_virtual_network.terraformvnet.name}"
    address_prefix       = "10.100.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "terraformpip" {
    name                         = "${local.base_computer_name}-PIP"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.terraformrg.name}"
    allocation_method            = "Static"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraformnsg" {
    name                = "terraformnsg"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.terraformrg.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Deployment"
    }
}

resource "azurerm_network_security_rule" "newssh" {
    name                        = "ssh2022"
    priority                    = 1002
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "2022"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.terraformrg.name}"
    network_security_group_name = "${azurerm_network_security_group.terraformnsg.name}"
}

# Create network interface
resource "azurerm_network_interface" "terraformnic" {
    name                      = "${local.base_computer_name}-NIC"
    location                  = "${var.location}"
    resource_group_name       = "${azurerm_resource_group.terraformrg.name}"
    network_security_group_id = "${azurerm_network_security_group.terraformnsg.id}"
    
    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.terraformvnetserversubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.terraformpip.id}"
    }

    tags = {
        environment = "Terraform Deployment"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.terraformrg.name}"
    }
    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "diagstorage99" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.terraformrg.name}"
    location                    = "${var.location}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Deployment"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "ubuntu1604" {
    name                  = local.base_computer_name
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.terraformrg.name}"
    network_interface_ids = ["${azurerm_network_interface.terraformnic.id}"]
    vm_size               = "${var.vm_size}"

    storage_os_disk {
        name              = "${local.base_computer_name}-osdisk"
        caching           = "ReadOnly"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
        disk_size_gb      = 50
    }

    storage_data_disk {
        name              = "${local.base_computer_name}-datadisk1"
        lun               = 0
        caching           = "ReadWrite"
        # create_option = Attach, FromImage, Empty
        create_option     = "Empty"
        managed_disk_type = "Premium_LRS"
        disk_size_gb      = 250
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
        # id          = "${var.image_id}"
    }

    os_profile {
        computer_name  = local.base_computer_name
        admin_username = "${var.ssh_username}"
        admin_password = "${var.ssh_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.diagstorage99.primary_blob_endpoint}"
    }

    identity {
    type = "SystemAssigned"
    }

    tags = {
        environment = "Terraform Deployment"
    }
}

resource "azurerm_role_assignment" "terraformrg" {
  scope              = "${azurerm_resource_group.terraformrg.id}"
  role_definition_name = "Contributor"
  principal_id       = "${lookup(azurerm_virtual_machine.ubuntu1604.identity[0], "principal_id")}"
}

resource "null_resource" "example_provisioner" {
  depends_on = [azurerm_virtual_machine.ubuntu1604]
  connection {
    type = "ssh"
    host = "${azurerm_public_ip.terraformpip.ip_address}"
    user = "${var.ssh_username}"
    password = "${var.ssh_password}"
    # private_key = "${file("/home/kunhoko/.ssh/id_rsa")}"
    port = "${var.ssh_port}"
    agent = false
  }
  provisioner "file" {
    source      = "files/datadisk_setup.sh"
    destination = "/tmp/datadisk_setup.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/datadisk_setup.sh",
        "/tmp/datadisk_setup.sh",
    ]
  }
  
}
# resource "azurerm_snapshot" "terraformsnapshot" {
#   name                = "ubuntu1604-osdisk-snapshot"
#   location            = "${azurerm_resource_group.terraformrg.location}"
#   resource_group_name = "${azurerm_resource_group.terraformrg.name}"
#   create_option       = "Copy"
#   source_uri          = "${azurerm_virtual_machine.ubuntu1604.storage_os_disk[0].managed_disk_id}"
# }

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
  // copy our example script to the server
output "public_ip_address" {
    value = "${azurerm_public_ip.terraformpip.ip_address}"
}
output "os_managed_disk_id" {
    value = "${azurerm_virtual_machine.ubuntu1604.storage_os_disk[0].managed_disk_id}" 
}
output "data_managed_disk_id" {
    value = "${azurerm_virtual_machine.ubuntu1604.storage_data_disk[0].managed_disk_id}"
}
output "resourcegroup_name" {
    value = "${azurerm_resource_group.terraformrg.name}"
}