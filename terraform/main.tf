resource "google_compute_network" "vpc_network" {
  name                    = "pinniped-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet" {
  name          = "pinniped-vpc-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true
}


resource "google_artifact_registry_repository" "pinniped-repo" {
  location      = var.gcp_region
  repository_id = "${var.app_name}-repo"
  description   = "Docker repo for pinniped facts"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "pinniped-api" {
  name     = var.app_name
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = "pinniped-vpc"
        subnetwork = "pinniped-vpc-subnet" 
      }
    }

  template {
    scaling {
      max_instance_count = 1  
      min_instance_count = 0  
    }
    containers {
        image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.pinniped-repo.repository_id}/${var.app_name}:latest"
        resources {
            limits = {
                cpu = "1"
                memory = "512Mi"
            }
        }
        ports {
            container_port = 8080
        }
    }
  }

    lifecycle {
        ignore_changes = [
        template[0].containers[0].image
        ]
    }
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
    name     = google_cloud_run_v2_service.pinniped-api.name
    location = google_cloud_run_v2_service.pinniped-api.location
    role     = "roles/run.invoker"
    member   = "allUsers" 
}

output "api_endpoint" {
  value       = google_cloud_run_v2_service.pinniped-api.uri
  description = "The url for the api backend"
}

resource "google_compute_address" "frontend_static_ip" {
  name   = "pinniped-frontend-static-ip"
  region = var.gcp_region
}


resource "google_compute_instance" "frontend_vm" {
  name         = "pinniped-frontend-vm"
  machine_type = "e2-micro"
  zone         = "${var.gcp_region}-a"
  allow_stopping_for_update = true

  tags = ["allow-http", "allow-https", "allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12" 
      size  = 10 
    }
  }

  service_account {
    email  = var.vm_service_account
    scopes = ["cloud-platform"]
  }

  network_interface {
    network = "pinniped-vpc"
    subnetwork = "pinniped-vpc-subnet"

    access_config {
      nat_ip = google_compute_address.frontend_static_ip.address
    }
  }

  metadata_startup_script = "sudo apt-get update && sudo apt-get install -y nginx"
}

