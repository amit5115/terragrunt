include {
  path = find_in_parent_folders()
}

locals {
  config = yamldecode(file("${get_terragrunt_dir()}/../config.yaml"))
}

terraform {
  source = "../../gcp_terraform/modules/mig"
}

# 🔥 SAME LOGIC
skip = !local.config.modules.migs.enabled

inputs = {
  migs = local.config.modules.migs.data
}
