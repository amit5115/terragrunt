resource "google_sql_database_instance" "this" {

  # for_each allows multiple instances with stable identity
  for_each = var.sql_instances

  # Cloud SQL instance name
  # Using provided name instead of each.key gives flexibility
  name = each.value.name

  # Database engine & version
  # Example: POSTGRES_15, MYSQL_8_0
  database_version = each.value.database_version

  # Region where instance will be created
  region = each.value.region

  # Prevent accidental deletion in production
  deletion_protection = each.value.deletion_protection

  settings {

    # Machine tier (CPU/RAM)
    tier = each.value.tier

    # Disk configuration
    disk_size = each.value.disk_size
    disk_type = each.value.disk_type

    # ZONAL or REGIONAL (HA)
    availability_type = each.value.availability_type

    # -------------------------
    # NETWORK CONFIGURATION
    # -------------------------
    ip_configuration {

      # Public IP control
      # Enterprises often disable this and use private IP
      ipv4_enabled = each.value.ipv4_enabled
    }

    # -------------------------
    # BACKUP CONFIGURATION
    # -------------------------
    backup_configuration {

      # Enables automated backups
      enabled = each.value.backup_enabled
    }

    # -------------------------
    # LABELS (COST + GOVERNANCE)
    # -------------------------
    user_labels = each.value.labels
  }
}
