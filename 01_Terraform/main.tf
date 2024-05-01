terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.100.0"
    }
  }
}

# Variablen sind in der Datei variables.tfvars definiert #

## Azure Subscription mit Variablen ##
provider "azurerm" {
#  skip_provider_registration = "true"
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}
## Ende -  Azure Subscription ##

# Ressourcengruppe abfragen/einlesen - "RG-AzureNetwork"
# Die Ressourcengruppe "RG-AzureNetwork" wird vorausgesetzt.
data "azurerm_resource_group" "RG" {
  name     = "RG-AzureNetwork"
  # name     = "${var.prefix}-resources"
  # location = "West Europe"
}

# Virtuelles Netzwerk abfragen/einlesen - "vnet-azure"
# Das virtuelle Netzwerk "vnet-azure" wird vorausgesetzt.
data "azurerm_virtual_network" "VNET" {
  name                = "vnet-azure"
  resource_group_name = data.azurerm_resource_group.RG.name
}

# Subnetz erstellen - "snet-DomainController"
resource "azurerm_subnet" "SUBNET_VNET-DomainController" {
  name                 = "snet-DomainController"
  virtual_network_name = data.azurerm_virtual_network.VNET.name
  resource_group_name  = data.azurerm_resource_group.RG.name
  address_prefixes     = ["172.16.3.0/24"]
}

# Subnetz erstellen - "snet-WebServer"
resource "azurerm_subnet" "SUBNET_VNET-Web-Server" {
  name                 = "snet-WebServer"
  virtual_network_name = data.azurerm_virtual_network.VNET.name
  resource_group_name  = data.azurerm_resource_group.RG.name
  address_prefixes     = ["172.16.4.0/24"]
}

# Subnetz erstellen - "snet-FileServer"
resource "azurerm_subnet" "SUBNET_VNET-File-Server" {
  name                 = "snet-FileServer"
  virtual_network_name = data.azurerm_virtual_network.VNET.name
  resource_group_name  = data.azurerm_resource_group.RG.name
  address_prefixes     = ["172.16.5.0/24"]
}

# Subnetz "snet-RDS-TerminalServer" erstellen
resource "azurerm_subnet" "SUBNET_VNET-RDS-Server" {
  name                 = "snet-RDS-TerminalServer"
  virtual_network_name = data.azurerm_virtual_network.VNET.name
  resource_group_name  = data.azurerm_resource_group.RG.name
  address_prefixes     = ["172.16.6.0/24"]
}

data "template_file" "setup" {
  template = file("scripts/setup.ps1")
}