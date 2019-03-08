variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-north1"
}

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

variable disk_image {
  description = "Disk image"
}

variable count_db {
  description = "Count DB instances"
  default     = "1"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db"
}

variable count_app {
  description = "Count App instances"
  default     = "1"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}

variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}

variable environment {
  description = "Environment: prod, stage, etc"
  default     = "stage"
}
