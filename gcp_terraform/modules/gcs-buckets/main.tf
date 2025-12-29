############################################
# CLOUD STORAGE BUCKETS (MAP CONTROLLED)
############################################
resource "google_storage_bucket" "this" {
  for_each = var.buckets
  # One bucket per map key

  name     = "amit-843493u439u422-${each.key}"
  # Enforces naming convention
  # Prevents random bucket names

  location      = each.value.location
  storage_class = each.value.storage_class

  force_destroy = var.forced_destroy
  # Guardrail: prod = false, dev = true

  ##########################################
  # VERSIONING
  ##########################################
  versioning {
    enabled = each.value.versioning
  }

  ##########################################
  # ENTERPRISE SECURITY
  ##########################################
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  ##########################################
  # LIFECYCLE RULE
  ##########################################
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = each.value.delete_after_days
    }
  }
}

############################################
# BUCKET IAM (PER BUCKET)
############################################
resource "google_storage_bucket_iam_member" "access" {
  for_each = var.buckets

  bucket = google_storage_bucket.this[each.key].name
  role   = each.value.iam_role
  member = each.value.iam_member
}
