variable "project_id" {
  description = "GCP Project ID in which to create example resources"
  type        = string
}

variable "region" {
  description = "Region in which to create regional resources."
  type        = string
  default     = "us-central1"
}
