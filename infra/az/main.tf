terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "e2113115-a6c7-4718-b618-e5d315b0247b"
}

# Define the resource group
resource "azurerm_resource_group" "terrafrom_azure_provider" {
  name     = "azure_provider"
  location = "switzerlandnorth"
}

# Define the virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = azurerm_resource_group.terrafrom_azure_provider.location
  resource_group_name = azurerm_resource_group.terrafrom_azure_provider.name
  address_space       = ["10.0.0.0/16"]
}

# Define a subnet
resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.terrafrom_azure_provider.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define a public IP
resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.terrafrom_azure_provider.location
  resource_group_name = azurerm_resource_group.terrafrom_azure_provider.name
  allocation_method   = "Dynamic"
}

# Define the network interface
resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.terrafrom_azure_provider.location
  resource_group_name = azurerm_resource_group.terrafrom_azure_provider.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id # Attach the public IP
  }

  accelerated_networking_enabled = true # Updated to the correct argument
}

# Define the virtual machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.terrafrom_azure_provider.name
  location            = azurerm_resource_group.terrafrom_azure_provider.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/dev_deployer.pub") # Path to your SSH public key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Output the public IP of the VM
output "public_ip_address" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_public_ip.example.ip_address
}
