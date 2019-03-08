provider "google" {
  version = "1.20.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source           = "../modules/app"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  app_disk_image   = "${var.app_disk_image}"
  count_app        = "${var.count_app}"
  environment      = "${var.environment}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = "${var.source_ranges}"
  environment   = "${var.environment}"
}
