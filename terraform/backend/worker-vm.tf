data "yandex_compute_image" "ubuntu-worker" {
  family = var.worker_config.os_family
}

resource "yandex_compute_instance" "avfomichev-kube-worker" {
  count = var.worker_config.count

  name        = "avfomichev-kube-worker-${count.index + 1}"
  hostname    = "avfomichev-kube-worker-${count.index + 1}"
  platform_id = var.worker_config.platform_id
  zone        = var.zone2

  resources {
    cores  = var.worker_config.cores
    memory = var.worker_config.memory
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-worker.image_id
      size     = var.worker_config.disk_size
    }
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "user:${var.ssh_public_key}"
    user-data = templatefile("${path.module}/cloud-config.yml", {
    ssh_public_key  = var.ssh_public_key
    ssh_private_key = var.ssh_private_key
})
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.avfomichev-subnet-b.id
    nat       = true
  }

  allow_stopping_for_update = true
}
