terraform {
  backend "gcs" {
    bucket = "_BUCKET_GCS_"
    prefix = "terraform/web-app-protection-example/dev"
  }
}