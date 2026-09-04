# Сервисный аккаунт
resource "yandex_iam_service_account" "tf-sa" {
  name        = "avfomichev-tf-sa"
  folder_id   = var.folder_id
  description = "Service Account for Terraform avfomichev"
}

# Назначение роли editor
resource "yandex_resourcemanager_folder_iam_member" "tf-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.tf-sa.id}"
}

# Статический ключ доступа
resource "yandex_iam_service_account_static_access_key" "tf-sa-key" {
  service_account_id = yandex_iam_service_account.tf-sa.id
  description        = "Static access key for avfomichev-tf-sa"
}

# S3 бакет
resource "yandex_storage_bucket" "tfstate" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.tf-sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf-sa-key.secret_key
  force_destroy = true

  provisioner "local-exec" {
    command = "echo 'export ACCESS_KEY=\"${yandex_iam_service_account_static_access_key.tf-sa-key.access_key}\"' > ../backend/backend.tfvars"
  }

  provisioner "local-exec" {
    command = "echo 'export SECRET_KEY=\"${yandex_iam_service_account_static_access_key.tf-sa-key.secret_key}\"' >> ../backend/backend.tfvars"
  }
}
