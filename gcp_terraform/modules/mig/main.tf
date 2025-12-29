resource "google_compute_instance_template" "this" {
  for_each     = var.migs
#   project      = var.project_id
  name_prefix  = "${each.key}-template-"
  machine_type = each.value.machine_type

  disk {
    boot         = true
    auto_delete = true
    source_image = each.value.image
  }

  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork
  }

  metadata_startup_script = <<EOF
#!/bin/bash
apt update -y
apt install -y apache2
echo "Hello from ${each.key}" > /var/www/html/index.html
systemctl restart apache2
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "this" {
  for_each = var.migs
#   project  = var.project_id
  name     = "${each.key}-hc"

  http_health_check {
    port         = each.value.health_check.port
    request_path = each.value.health_check.request_path
  }
}


resource "google_compute_region_instance_group_manager" "this" {
  for_each = var.migs
#   project  = var.project_id
  name     = each.key
  region   = each.value.region

  base_instance_name = each.key

  version {
    instance_template = google_compute_instance_template.this[each.key].id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.this[each.key].id
    initial_delay_sec = 60
  }
}

resource "google_compute_region_autoscaler" "this" {
  for_each = var.migs
#   project  = var.project_id
  region   = each.value.region
  name     = "${each.key}-autoscaler"
  target   = google_compute_region_instance_group_manager.this[each.key].id

  autoscaling_policy {
    min_replicas = each.value.autoscaling.min_replicas
    max_replicas = each.value.autoscaling.max_replicas

    cpu_utilization {
      target = each.value.autoscaling.cpu_target
    }
  }
}

resource "google_compute_backend_service" "this" {
  for_each  = var.migs
#   project   = var.project_id
  name      = "${each.key}-backend"
  protocol  = "HTTP"
  port_name = "http"

  health_checks = [
    google_compute_health_check.this[each.key].id
  ]

  backend {
    group = google_compute_region_instance_group_manager.this[each.key].instance_group
  }
}

resource "google_compute_url_map" "this" {
  for_each        = var.migs
#   project         = var.project_id
  name            = "${each.key}-url-map"
  default_service = google_compute_backend_service.this[each.key].id
}

resource "google_compute_target_http_proxy" "this" {
  for_each = var.migs
#   project  = var.project_id
  name     = "${each.key}-http-proxy"
  url_map  = google_compute_url_map.this[each.key].id
}

resource "google_compute_global_forwarding_rule" "this" {
  for_each   = var.migs
#   project    = var.project_id
  name       = "${each.key}-fw-rule"
  port_range = each.value.load_balancer.port
  target     = google_compute_target_http_proxy.this[each.key].id
}
