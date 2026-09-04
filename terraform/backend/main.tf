# VPC
resource "yandex_vpc_network" "avfomichev-vpc" {
  name = var.vpc_name
}

# Подсеть A (зона ru-central1-a)
resource "yandex_vpc_subnet" "avfomichev-subnet-a" {
  name           = var.subnet1_name
  zone           = var.zone1
  network_id     = yandex_vpc_network.avfomichev-vpc.id
  v4_cidr_blocks = var.cidr1
}

# Подсеть B (зона ru-central1-b)
resource "yandex_vpc_subnet" "avfomichev-subnet-b" {
  name           = var.subnet2_name
  zone           = var.zone2
  network_id     = yandex_vpc_network.avfomichev-vpc.id
  v4_cidr_blocks = var.cidr2
}

# Cloud-init конфигурация
data "local_file" "cloudinit" {
  filename = "${path.module}/cloud-config.yml"
}
