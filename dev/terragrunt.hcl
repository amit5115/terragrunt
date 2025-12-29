locals {
  config = yamldecode(file("config.yaml"))
}

inputs = {
  project_id = local.config.globals.project_id
  region     = local.config.globals.region
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "google" {
  project = "${local.config.globals.project_id}"
  region  = "${local.config.globals.region}"
}
EOF
}
