variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group en Azure para el reto"
  default     = "rg-mbco-reto-uks"
}

variable "location" {
  type        = string
  description = "Región de Azure donde se desplegará la infraestructura"
  default     = "East US"
}

variable "cluster_name" {
  type        = string
  description = "Nombre obligatorio del clúster AKS exigido por el desafío"
  default     = "aks-mbco-reto" #[cite: 1]
}

variable "node_count" {
  type        = number
  description = "Cantidad inicial de nodos para el clúster de Kubernetes"
  default     = 2
}