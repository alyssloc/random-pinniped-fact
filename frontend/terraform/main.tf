# 1. Reserve a Static Public IP Address for the Frontend
resource "google_compute_address" "frontend_static_ip" {
  name   = "pinniped-frontend-static-ip"
  region = var.gcp_region
}

resource "google_compute_instance" "frontend_vm" {
  name         = "pinniped-frontend-vm"
  machine_type = "e2-micro"
  zone         = "${var.gcp_region}-a"

  tags = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12" 
      size  = 10 
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.frontend_static_ip.address
    }
  }

  metadata_startup_script = "sudo apt-get update && sudo apt-get install -y nginx"
}


resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] # Open to global traffic
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

output "frontend_public_ip" {
  value       = google_compute_address.frontend_static_ip.address
  description = "Point your custom domain DNS 'A' record to this IP address."
}