variable "gcp_project_id" {
  type        = string
  description = "The unique ID of your Google Cloud Platform project"
  default     = "your-gcp-project-id" 
}

variable "gcp_region" {
  type        = string
  description = "The target data center region for deployment"
  default     = "us-central1"
}

variable "app_name" {
  type        = string
  default     = "pinniped-fact-api"
}

variable "vm_service_account" {
  type        = string
  description = "Service account for VM"
  default     = "vm_service_account"
}

