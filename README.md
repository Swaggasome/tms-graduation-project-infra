# tms-graduation-project-infra

Terraform-репозиторий для создания основной инфраструктуры проекта в Yandex Cloud.

Репозиторий разворачивает:

- Managed Kubernetes cluster;
- Kubernetes node group;
- VPC network;
- VPC subnet;
- Container Registry;
- service account для управления Kubernetes cluster;
- service account для Kubernetes node group;
- service account для GitHub Actions;
- authorized key для GitHub Actions;
- Object Storage bucket для static files;
- static access keys для static files bucket;
- IAM-роли для service accounts.

Terraform state хранится удалённо в Yandex Object Storage через S3-compatible backend.

---

## Архитектура Terraform state

Этот репозиторий использует remote backend:

```hcl
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    bucket = "terraform-state-bucket-for-tms-guardian-project"
    region = "ru-central1-a"
    key    = "lab/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}


