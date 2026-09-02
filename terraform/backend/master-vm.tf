data "yandex_compute_image" "ubuntu-master" {
  family = var.master_config.os_family
}

resource "yandex_compute_instance" "avfomichev-kube-master" {
  count = var.master_config.count

  name        = "avfomichev-kube-master-${count.index + 1}"
  hostname    = "avfomichev-kube-master-${count.index + 1}"
  platform_id = var.master_config.platform_id
  zone        = var.zone1

  resources {
    cores  = var.master_config.cores
    memory = var.master_config.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-master.image_id
      size     = var.master_config.disk_size
    }
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "user:${var.ssh_public_key}"
    user-data          = data.template_file.cloudinit.rendered
  }

  scheduling_policy {
    preemptible = false
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.avfomichev-subnet-a.id
    nat       = true
  }

  allow_stopping_for_update = true
}
