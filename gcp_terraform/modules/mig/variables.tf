# variable "project_id" {
#   type = string
# }

# variable "region" {
#   type = string
# }

variable "migs" {
  description = "Map of Managed Instance Groups"
  type = map(object({
    region  = string
    zones   = list(string)

    machine_type = string
    image        = string
    network      = string
    subnetwork   = string

    autoscaling = object({
      min_replicas = number
      max_replicas = number
      cpu_target   = number
    })

    health_check = object({
      port         = number
      request_path = string
    })

    load_balancer = object({
      type = string
      port = number
    })
  }))
}
