resource "yandex_kubernetes_cluster" "k8s_cluster" {
  name        = var.cluster_name
  description = "Managed Kubernetes Cluster"
  network_id  = yandex_vpc_network.k8s_network.id

  master {
    version = var.k8s_version
    zonal {
      zone      = var.default_zone
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
    }
    public_ip = true # Делает мастер доступным из интернета. Для production лучше настроить VPN и выставить false.
  }

  service_account_id      = yandex_iam_service_account.k8s_cluster.id
  node_service_account_id = yandex_iam_service_account.k8s_nodes.id

  # Канал обновлений: RAPID, REGULAR или STABLE
  release_channel = "REGULAR"

  # Включаем сетевые политики Calico для безопасности (опционально)
  network_policy_provider = "CALICO"

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  # Важный момент для корректного удаления: зависимость от назначения ролей
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_cluster_editor,
    yandex_resourcemanager_folder_iam_member.k8s_nodes_puller,
    yandex_resourcemanager_folder_iam_member.k8s_nodes_logs
  ]
}
