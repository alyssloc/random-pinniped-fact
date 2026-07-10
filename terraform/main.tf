resource "google_artifact_registry_repository" "pinniped-repo" {
  location      = var.gcp_region
  repository_id = "${var.app_name}-repo"
  description   = "Docker repo for pinniped facts"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "pinniped-api" {
  name     = var.app_name
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_ALL"

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