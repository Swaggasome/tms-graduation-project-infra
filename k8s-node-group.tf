resource "yandex_kubernetes_node_group" "k8s_nodes" {
  cluster_id  = yandex_kubernetes_cluster.k8s_cluster.id
  name        = "${var.cluster_name}-node-group"
  description = "Main node group for K8S cluster"
  version     = var.k8s_version

  instance_template {
    platform_id = "standard-v2" # Платформа: standard-v3 (Intel Ice Lake), standard-v2 (Intel Broadwell)

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 50 # 100% гарантированной производительности vCPU
    }

    boot_disk {
      type = "network-ssd" # Тип диска: network-ssd, network-hdd
      size = 64            # Размер в ГБ (минимальный для K8S - 64 ГБ)[citation:4]
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.k8s_subnet.id]
      nat        = true # Присвоить публичный IP для выхода в интернет
    }

    scheduling_policy {
      preemptible = false # Прерываемые ВМ дешевле, но могут быть остановлены в любой момент
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2 # Количество узлов в группе
    }
  }

  allocation_policy {
    location {
      zone = var.default_zone
    }
  }

  labels = {
    group = "main-workers"
  }

  node_labels = {
    "node-role" = "worker"
  }
}
