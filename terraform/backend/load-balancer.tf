# Группа целей для балансировщика
resource "yandex_lb_target_group" "avfomichev-balancer-group" {
  name = "avfomichev-balancer-group"

  dynamic "target" {
    for_each = yandex_compute_instance.avfomichev-kube-worker
    content {
      subnet_id = target.value.network_interface.0.subnet_id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

# Балансировщик для Grafana
resource "yandex_lb_network_load_balancer" "avfomichev-nlb-grafana" {
  name = "avfomichev-nlb-grafana"

  listener {
    name        = "grafana-listener"
    port        = 80
    target_port = 30070
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.avfomichev-balancer-group.id

    healthcheck {
      name = "grafana-healthcheck"
      tcp_options {
        port = 30070
      }
    }
  }
}

# Балансировщик для веб-приложения
resource "yandex_lb_network_load_balancer" "avfomichev-nlb-webapp" {
  name = "avfomichev-nlb-webapp"

  listener {
    name        = "webapp-listener"
    port        = 80
    target_port = 30071
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.avfomichev-balancer-group.id

    healthcheck {
      name = "webapp-healthcheck"
      tcp_options {
        port = 30071
      }
    }
  }
}
