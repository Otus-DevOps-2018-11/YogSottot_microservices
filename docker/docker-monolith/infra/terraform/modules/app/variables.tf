variable zone {
  description = "Zone"
  default     = "europe-north1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable count_app {
  description = "Count App instances"
  default     = "1"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}

variable db_local_ip {
  type        = "list"
  description = "DB local ip address"
  default     = ["127.0.0.1"]
}

variable environment {
  description = "Environment: prod, stage, etc"
  default     = "prod"
}
