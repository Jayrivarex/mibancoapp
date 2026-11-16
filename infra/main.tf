provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-mbco-reto-core"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-mbco-reto"

  # Corrección para CKV_AZURE_115: Habilita el clúster privado
  private_cluster_enabled = true

  # Corrección para CKV_AZURE_171: Define el canal de actualización automática
  automatic_upgrade_channel = "patch"

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