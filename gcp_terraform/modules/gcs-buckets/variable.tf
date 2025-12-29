
variable "buckets" {
  description = "Map of GCS buckets"
  type = map(object({
    location          = string
    storage_class     = string
    versioning        = bool
    delete_after_days = number
    iam_role          = string
    iam_member        = string
    # forced_destroy = bool
  }))
}

variable "forced_destroy" {
  type = bool
}

# variable "iam_role" {
#   type = string
# }

# variable "iam_member" {
#   type = string
# }
