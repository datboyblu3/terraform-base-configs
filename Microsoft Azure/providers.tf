terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
}

#Create resource group
resource "azurerm_resource_group" "tmp-rg" {
  name     = "tmp-rg"
  location = "East US"
  tags = {
    environment = "dev" #indiciates what environment your resources are deployed to
  }
}

#Create security group
resource "azurerm_network_security_group" "tmp-sg" {
  name                = "tmp-sg"
  location            = azurerm_resource_group.tmp-rg.location
  resource_group_name = azurerm_resource_group.tmp-rg.name

  tags = {
    environment = "dev"
  }
}