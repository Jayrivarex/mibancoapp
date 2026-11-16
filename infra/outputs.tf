output "kubernetes_cluster_name" {
  description = "Nombre oficial del clúster AKS desplegado[cite: 1]"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  description = "Nombre del Resource Group asociado"
  value       = azurerm_resource_group.rg.name
}

output "cluster_endpoint" {
  description = "Endpoint del API Server del clúster de Kubernetes"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "kube_config" {
  description = "Configuración cruda del clúster para la autenticación segura del pipeline"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "acr_login_server" {
  description = "URL del servidor de registro del ACR"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Usuario administrador del ACR"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Contraseña de administrador del ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}