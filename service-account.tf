# Сервисный аккаунт для управления кластером
resource "yandex_iam_service_account" "k8s_cluster" {
  name        = "${var.cluster_name}-cluster-sa"
  description = "Service Account for managing K8S cluster resources"
}

# Назначение роли editor на каталог для управления ресурсами
resource "yandex_resourcemanager_folder_iam_member" "k8s_cluster_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

# Сервисный аккаунт для узлов кластера
resource "yandex_iam_service_account" "k8s_nodes" {
  name        = "${var.cluster_name}-nodes-sa"
  description = "Service Account for K8S worker nodes"
}

# Назначение роли container-registry.images.puller для доступа к Container Registry
resource "yandex_resourcemanager_folder_iam_member" "k8s_nodes_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

# Назначение роли logging.writer для отправки логов
resource "yandex_resourcemanager_folder_iam_member" "k8s_nodes_logs" {
  folder_id = var.folder_id
  role      = "logging.writer"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

resource "yandex_iam_service_account" "github_actions" {
  folder_id   = var.folder_id
  name        = "github-actions-deployer"
  description = "Service account for GitHub Actions CI/CD"
}


resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.github_actions.id}"
}

# Назначаем роль для работы с Container Registry
resource "yandex_resourcemanager_folder_iam_member" "registry_pusher" {
  folder_id   = var.folder_id
  role        = "container-registry.images.pusher"
  member      = "serviceAccount:${yandex_iam_service_account.github_actions.id}"
}

resource "yandex_iam_service_account_key" "github_actions_key" {
  service_account_id = yandex_iam_service_account.github_actions.id
  description        = "Authorized key for GitHub Actions"
  key_algorithm      = "RSA_4096"
  # Без output_to_lockbox
}

locals {
  # Преобразуем ключ в нужный формат
  full_json_key = jsonencode({
    id                 = yandex_iam_service_account_key.github_actions_key.id
    service_account_id = yandex_iam_service_account_key.github_actions_key.service_account_id
    created_at         = yandex_iam_service_account_key.github_actions_key.created_at
    key_algorithm      = yandex_iam_service_account_key.github_actions_key.key_algorithm
    public_key         = yandex_iam_service_account_key.github_actions_key.public_key
    private_key        = yandex_iam_service_account_key.github_actions_key.private_key
  })
}
