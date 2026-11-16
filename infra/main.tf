terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Creación del Resource Group para aislar los recursos del reto
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Aprovisionamiento automatizado del clúster AKS exigido en el reto
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-mbco-reto-dns"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Challenge"
    Owner       = "DevSecOps-Lead"
    Project     = "Mibanco-Reto"
  }
}

# Creación automatizada del Azure Container Registry (ACR) requerido para la Parte B
resource "azurerm_container_registry" "acr" {
  name                = "acrmbcoreto"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}