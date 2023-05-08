# Terraform docs re: configuring back end: https://www.terraform.io/docs/backends/types/gcs.html
terraform {
  backend "gcs" {
    prefix = "terraform/instance-group"
    bucket = "bkt-prj-sandbox-devops-9000-dev"
  }
}