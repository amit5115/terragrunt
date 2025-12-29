include {
  path = find_in_parent_folders()
}

locals {
  config = yamldecode(file("${get_terragrunt_dir()}/../config.yaml"))
}

terraform {
  source = "../../gcp_terraform/modules/gcs-buckets"
}

# 🔥 SAME LOGIC
skip = !local.config.modules.buckets.enabled

inputs = {
  buckets = local.config.modules.buckets.data
  forced_destroy = local.config.modules.buckets.forced_destroy
}
