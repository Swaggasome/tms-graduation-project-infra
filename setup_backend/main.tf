provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone # зона, которая будет использована по умолчанию
}

# Создаем сервисный аккаунт
resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = var.service_account
}

# Даем права на запись для этого сервисного аккаунта
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создаем ключи доступа Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

# Создаем Хранилище
resource "yandex_storage_bucket" "state" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  force_destroy = true
}

resource "yandex_storage_bucket" "staticfiles" {
  bucket     = "smartmeeting-static"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  force_destroy = true
  default_storage_class   = "STANDARD"
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
  max_size                = 214748365
  versioning {
    enabled = false
  }
}

resource "yandex_container_registry" "smartmeeting" {
  name      = "smartmeeting"
}
