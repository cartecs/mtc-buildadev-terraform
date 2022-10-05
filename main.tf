terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "rg-tf-test" {
  name     = "rg-tf-test"
  location = "Central US"
  tags = {
    environment = "dev"
    project     = "mtc-tf-azure"
  }
}

resource "azurerm_virtual_network" "vnet-mtc" {
  name                = "vnet-mtc"
  resource_group_name = azurerm_resource_group.rg-tf-test.name
  location            = azurerm_resource_group.rg-tf-test.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
    project     = "mtc-tf-azure"
  }
}

resource "azurerm_subnet" "subnet-mtc" {
  name                 = "subnet-mtc"
  resource_group_name  = azurerm_resource_group.rg-tf-test.name
  virtual_network_name = azurerm_virtual_network.vnet-mtc.name
  address_prefixes     = ["10.123.1.0/24"]

}

resource "azurerm_network_security_group" "nsg-mtc" {
  name                = "nsg-mtc"
  resource_group_name = azurerm_resource_group.rg-tf-test.name
  location            = azurerm_resource_group.rg-tf-test.location

  tags = {
    environment = "dev"
    project     = "mtc-tf-azure"
  }
}

resource "azurerm_network_security_rule" "nsr-nsg-mtc-rule1" {
  name                        = "nsr-nsg-mtc-rule1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "98.97.82.244/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-tf-test.name
  network_security_group_name = azurerm_network_security_group.nsg-mtc.name
}

resource "azurerm_subnet_network_security_group_association" "snsga-subnet-mtc" {
  subnet_id                 = azurerm_subnet.subnet-mtc.id
  network_security_group_id = azurerm_network_security_group.nsg-mtc.id
}