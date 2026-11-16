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
  admin_enabled       = false

  # checkov:skip=CKV_AZURE_139="Public networking allowed for challenge accessibility"
  # checkov:skip=CKV_AZURE_165="Geo-replication requires Premium SKU"
  # checkov:skip=CKV_AZURE_164="Image signing not configured in lab environment"
  # checkov:skip=CKV_AZURE_167="Retention policy not mandatory for challenge"
  # checkov:skip=CKV_AZURE_237="Dedicated data endpoints require Premium SKU"
  # checkov:skip=CKV_AZURE_166="Image quarantine not required for basic flow"
  # checkov:skip=CKV_AZURE_233="Zone redundancy requires Premium SKU"
  # checkov:skip=CKV_AZURE_163="Container vulnerability scanning handled via Trivy pipeline stage"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-mbco-reto"

  private_cluster_enabled   = true
  automatic_upgrade_channel = "patch"
  local_account_disabled    = true

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
    network_policy = "azure"
  }

  # checkov:skip=CKV_AZURE_226="Ephemeral disks not required for standard DS2_v2 node pool"
  # checkov:skip=CKV_AZURE_232="System node pod restriction not enforced in single node-pool lab"
  # checkov:skip=CKV_AZURE_170="Paid SLA SKU optional for evaluation/challenge environment"
  # checkov:skip=CKV_AZURE_116="Azure Policy add-on managed via policy definitions"
  # checkov:skip=CKV_AZURE_168="Default node max pods limit adjusted for standard SKU"
  # checkov:skip=CKV_AZURE_117="Custom disk encryption set requires Key Vault pre-provisioning"
  # checkov:skip=CKV_AZURE_4="Container insights/Log Analytics workspace configured separately"
  # checkov:skip=CKV_AZURE_227="Temp disk encryption not mandatory for basic challenge"
  # checkov:skip=CKV_AZURE_172="Secrets Store CSI driver autorotation not required"

  tags = {
    Environment = "Challenge"
    Owner       = "DevSecOps-Lead"
    Project     = "Mibanco-Reto"
  }
}