output "bucket_names" {
  value = keys(google_storage_bucket.this)
}
