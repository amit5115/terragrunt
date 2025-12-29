variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    machine_type = string
    zone         = string
    image        = string
  }))
}
