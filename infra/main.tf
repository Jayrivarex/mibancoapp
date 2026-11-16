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
  sku                 = "Standard"
  admin_enabled       = false # Mitiga CKV_AZURE_137: Desactiva cuenta admin local
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-mbco-reto"

  # CKV_AZURE_115: Habilita el clúster privado
  private_cluster_enabled = true

  # CKV_AZURE_171: Canal de actualización automática
  automatic_upgrade_channel = "patch"

  # CKV_AZURE_141: Desactiva cuentas locales de administración en AKS
  local_account_disabled = true

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure" # CKV_AZURE_7: Configura Network Policy obligatoria
  }

  tags = {
    Environment = "Challenge"
    Owner       = "DevSecOps-Lead"
    Project     = "Mibanco-Reto"
  }
}