variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key content"
  type        = string
  sensitive   = true
}

variable "default_zone" {
  description = "Default availability zone"
  default     = "ru-central1-a"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  default     = "my-k8s-cluster"
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = "1.33"
}

variable "bucket_name" {
  description = "Your Bucket Name"
  type        = string
}

variable "registry_id" {
  description = "Yandex Cloud Container Registry ID"
  type        = string
}