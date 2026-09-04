variable "cloud_id" {
  type        = string
  description = "ID облака"
}

variable "folder_id" {
  type        = string
  description = "ID папки"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
}

variable "bucket_name" {
  description = "Имя бакета для хранения состояния"
  type        = string
  default     = "avfomichev-tfstate"
}

variable "service_account_key_file" {
  description = "Path to service account key file"
  type        = string
}
