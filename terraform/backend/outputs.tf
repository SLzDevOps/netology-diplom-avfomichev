output "all_vms" {
  value = flatten([
    [for i in yandex_compute_instance.avfomichev-kube-master : {
      name         = i.name
      ip_external  = i.network_interface[0].nat_ip_address
      ip_internal  = i.network_interface[0].ip_address
    }],
    [for i in yandex_compute_instance.avfomichev-kube-worker : {
      name         = i.name
      ip_external  = i.network_interface[0].nat_ip_address
      ip_internal  = i.network_interface[0].ip_address
    }]
  ])
}

output "grafana_lb_address" {
  value = yandex_lb_network_load_balancer.avfomichev-nlb-grafana.listener.*.external_address_spec[0].*.address
  description = "Адрес балансировщика для Grafana"
}

output "webapp_lb_address" {
  value = yandex_lb_network_load_balancer.avfomichev-nlb-webapp.listener.*.external_address_spec[0].*.address
  description = "Адрес балансировщика для веб-приложения"
}
