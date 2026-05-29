output "k8s_id" {
  value     = yandex_kubernetes_cluster.k8s_cluster.id
  sensitive = true
}

# output "registry_id" {
#   value = yandex_container_registry.smartmeeting.id
# }

# Получить ключ:
output "yc_sa_json_credentials_raw" {
  description = "Raw JSON key (copy this to GitHub Secrets)"
  value       = local.full_json_key
  sensitive   = true
}