variable "sql_instances" {
  description = <<EOT
Map of Cloud SQL instances.

Each key represents a logical database instance.
Value is an object defining configuration for that instance.

Enterprise reason:
- Map gives stable identity
- Object enforces structure
- Easy to scale without changing module
EOT

  type = map(object({

    # -------------------------
    # CORE IDENTIFICATION
    # -------------------------
    name            = string
    database_version = string
    region          = string

    # -------------------------
    # MACHINE & STORAGE
    # -------------------------
    tier             = string
    disk_size        = number
    disk_type        = string
    availability_type = string

    # -------------------------
    # SECURITY & NETWORKING
    # -------------------------
    deletion_protection = bool
    ipv4_enabled        = bool

    # -------------------------
    # BACKUP & RELIABILITY
    # -------------------------
    backup_enabled = bool

    # -------------------------
    # LABELS (MANDATORY IN ENTERPRISE)
    # -------------------------
    labels = map(string)
  }))
}
