# Создание облачной сети
resource "yandex_vpc_network" "k8s_network" {
  name        = "${var.cluster_name}-network"
  description = "Network for K8S cluster"
}

# Создание подсети
resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = "${var.cluster_name}-subnet"
  description    = "Subnet for K8S cluster"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.k8s_network.id
  v4_cidr_blocks = ["10.1.0.0/16"]
}
