terraform {
  backend "gcs" {
    bucket = "" #!TODO
    prefix = "terraform/juiceshop_example_mig/business_unit_1/development"
  }
}