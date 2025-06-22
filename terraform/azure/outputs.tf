output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].raw_kube_config
  sensitive = true
}
