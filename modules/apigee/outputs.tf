output "apigee_org_id" {
  value = split("/", module.apigee_core.org_id)[1]
  description = "Apigee org ID (same as GCP project ID)"
}