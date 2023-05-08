resource "google_compute_instance_group" "instance_group" {
  count       = var.instances != null ? 1 : 0
  name        = var.name
  project     = var.project_id
  network     = var.network
  zone        = var.zone
  description = var.description
  instances   = var.instances
  dynamic "named_port" {
    for_each = var.named_port
    content {
      name = each.key
      port = each.value
    }
  }
}