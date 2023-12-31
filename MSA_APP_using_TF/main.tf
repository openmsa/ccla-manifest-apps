terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.42.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
}

# data "terraform_remote_state" "aks" {
#   backend = "local"

#   config = {
#     path = var.cluster_terraform_remote_state 
#   }
# }

# Retrieve AKS cluster information
# provider "azurerm" {
#   features {}
# }

# data "azurerm_kubernetes_cluster" "cluster" {
#   name                = data.terraform_remote_state.aks.outputs.kubernetes_cluster_name
#   resource_group_name = data.terraform_remote_state.aks.outputs.resource_group_name
# }
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

variable "kubeconfig_path" {
  description = "Path to a kubeconfig file, set from ENV variable"
  default     = ""
}