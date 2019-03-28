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

variable source_ranges {
  description = "Allowed IP addresses"
  default     = ["0.0.0.0/0"]
}

variable environment {
  description = "Environment: prod, stage, etc"
  default     = "stage"
}

variable cluster_name {
  description = "name of the cluster gke"
  default     = "reddit-test"
}

variable count_gke_node {
  description = "Count GKE node"
  default     = "2"
}

variable gke_cluster_version {
  description = "GKE cluster version"
  default     = "1.12.5-gke.5"
}

variable gke_machine_type {
  description = "GKE machine type"
  default     = "g1-small"
}

variable image_type {
  description = "GKE Image type"
  default     = "COS"
}

variable disk_type {
  description = "GKE Disk type"
  default     = "pd-standard"
}

variable disk_size {
  description = "GKE Disk size"
  default     = "20"
}
