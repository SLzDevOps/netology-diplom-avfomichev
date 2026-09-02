resource "local_file" "hosts_cfg_kubespray" {
  content = templatefile("${path.module}/hosts.tftpl", {
    workers = yandex_compute_instance.avfomichev-kube-worker
    masters = yandex_compute_instance.avfomichev-kube-master
  })
  filename = "../../../kubespray/inventory/mycluster/hosts.yaml"

  depends_on = [
    yandex_compute_instance.avfomichev-kube-master,
    yandex_compute_instance.avfomichev-kube-worker
  ]
}
