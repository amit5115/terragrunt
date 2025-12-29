############################################
# GCP VM CREATION USING MAP
############################################
resource "google_compute_instance" "vm" {
  for_each = var.vms
  # for_each loops over map
  # Key becomes VM name

  name         = each.key
  machine_type = each.value.machine_type
  zone         = each.value.zone

  ##########################################
  # BOOT DISK
  ##########################################
  boot_disk {
    initialize_params {
      image = each.value.image
    }
  }

  ##########################################
  # NETWORK
  ##########################################
  network_interface {
    network = "default"

    access_config {}
    # Public IP
  }

  ##########################################
  # TAGS (Firewall, Monitoring)
  ##########################################
  tags = ["controlled-vm"]
}
