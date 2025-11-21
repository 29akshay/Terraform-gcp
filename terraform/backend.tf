terraform {
  backend "gcs" {
    bucket = "terraform-logging"
    prefix = "terraform/state"
  }
}
