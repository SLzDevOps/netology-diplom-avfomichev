# Облачные переменные
variable "cloud_id" {
  type        = string
  description = "ID облака"
}

variable "folder_id" {
  type        = string
  description = "ID папки"
}

variable "service_account_key_file" {
  description = "Path to service account key file"
  type        = string
}

# Зоны доступности
variable "zone1" {
  type        = string
  default     = "ru-central1-a"
  description = "Первая зона доступности"
}

variable "zone2" {
  type        = string
  default     = "ru-central1-b"
  description = "Вторая зона доступности"
}

# VPC
variable "vpc_name" {
  type        = string
  default     = "avfomichev-vpc"
  description = "Имя VPC сети"
}

variable "subnet1_name" {
  type        = string
  default     = "avfomichev-subnet-a"
}

variable "subnet2_name" {
  type        = string
  default     = "avfomichev-subnet-b"
}

variable "cidr1" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "cidr2" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# SSH ключи
variable "ssh_public_key" {
  description = "Содержимое публичного SSH-ключа"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "Содержимое приватного SSH-ключа"
  type        = string
  sensitive   = true
}

# Настройки мастер-ноды
variable "master_config" {
  description = "Настройки мастер-ноды"
  type = object({
    count       = number
    cores       = number
    memory      = number
    disk_size   = number
    platform_id = string
    os_family   = string
  })
  default = {
    count       = 1
    cores       = 4
    memory      = 8
    disk_size   = 20
    platform_id = "standard-v3"
    os_family   = "ubuntu-2404-lts"
  }
}

# Настройки воркер-нод
variable "worker_config" {
  description = "Настройки воркер-нод"
  type = object({
    count       = number
    cores       = number
    memory      = number
    disk_size   = number
    platform_id = string
    os_family   = string
  })
  default = {
    count       = 2
    cores       = 4
    memory      = 4
    disk_size   = 20
    platform_id = "standard-v3"
    os_family   = "ubuntu-2404-lts"
  }
}
