include {
  path = find_in_parent_folders()
}

locals {
  config = yamldecode(file("${get_terragrunt_dir()}/../config.yaml"))
}

terraform {
  source = "../../gcp_terraform/modules/sql"
}

# 🔥 SAME LOGIC
skip = !local.config.modules.sql_instances.enabled

inputs = {
   sql_instances = local.config.modules.sql_instances.data
}
