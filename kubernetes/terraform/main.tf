provider "google" {
  version = "1.20.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = "${var.count_gke_node}"

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  node_config {
    disk_size_gb = "${var.disk_size}"
    disk_type    = "${var.disk_type}"
    image_type   = "${var.image_type}"
    machine_type = "${var.gke_machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }
  }

  #  ip_allocation_policy {
  #    use_ip_aliases {
  #      disabled = true
  #    }
  #  }

  timeouts {
    create = "30m"
    update = "40m"
  }
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project} && files/deploy.sh"
  }
}

module "vpc" {
  source        = "./modules/vpc"
  source_ranges = "${var.source_ranges}"
  environment   = "${var.environment}"
}
