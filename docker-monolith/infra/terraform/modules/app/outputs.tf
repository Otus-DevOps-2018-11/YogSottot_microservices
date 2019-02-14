output "apps_external_ip" {
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "apps_local_ip" {
  value = "${google_compute_instance.app.*.network_interface.0.address}"
}
