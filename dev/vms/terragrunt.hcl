include {
  path = find_in_parent_folders()
}

locals {
  config = yamldecode(file("${get_terragrunt_dir()}/../config.yaml"))
}

terraform {
  source = "../../gcp_terraform/modules/gcp-vm"
}

# 🔥 THIS IS THE MAGIC
skip = !local.config.modules.vms.enabled

inputs = {
  vms = local.config.modules.vms.data
}

