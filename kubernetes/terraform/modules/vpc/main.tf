resource "google_compute_firewall" "firewall_kubernetes" {
  name        = "default-allow-kubernetes-${var.environment}"
  network     = "default"
  description = "Allow kubernetes from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = "${var.source_ranges}"
}
