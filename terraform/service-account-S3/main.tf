terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.178.0"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}

# Сервисный аккаунт
resource "yandex_iam_service_account" "tf-sa" {
  name        = "avfomichev-tf-sa"
  folder_id   = var.folder_id
  description = "Service Account for Terraform (avfomichev)"
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

# S3 бакет для хранения состояния
resource "yandex_storage_bucket" "tfstate" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.tf-sa-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf-sa-key.secret_key
  force_destroy = true

  # Сохраняем ключи в файл для дальнейшего использования
  provisioner "local-exec" {
    command = "echo 'export ACCESS_KEY=\"${yandex_iam_service_account_static_access_key.tf-sa-key.access_key}\"' > ../backend/backend.tfvars"
  }

  provisioner "local-exec" {
    command = "echo 'export SECRET_KEY=\"${yandex_iam_service_account_static_access_key.tf-sa-key.secret_key}\"' >> ../backend/backend.tfvars"
  }
}

output "service_account_id" {
  value = yandex_iam_service_account.tf-sa.id
}

output "bucket_name" {
  value = yandex_storage_bucket.tfstate.bucket
}
