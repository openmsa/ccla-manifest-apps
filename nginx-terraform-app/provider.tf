provider "kubernetes" {
  config_path = var.kubeconfig_path
}

variable "kubeconfig_path" {
  description = "Path to a kubeconfig file, set from ENV variable"
  default     = ""
}