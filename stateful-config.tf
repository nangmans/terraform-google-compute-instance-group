resource "google_compute_per_instance_config" "instance_config" {
  # Stateful로 설정하고 싶을때 사용하는 Resource
  # Stateful과 Autoscaling은 상충됨/동시 사용 불가능
  for_each                         = var.stateful_config == {} ? {} : var.is_regional ? {} : var.stateful_config
  name                             = each.key
  instance_group_manager           = try(google_compute_instance_group_manager.instance_group.0.id, null)
  zone                             = var.zone
  project                          = var.project_id
  minimal_action                   = each.value.minimal_action
  most_disruptive_allowed_action   = each.value.most_disruptive_allowed_action
  remove_instance_state_on_destroy = each.value.remove_instance_state_on_destroy

  dynamic "preserved_state" {
    for_each = var.stateful_config.preserved_state != null ? [""] : []
    content {
      metadata = each.value.preserved_state.metadata
      dynamic "disk" {
        for_each = each.value.preserved_state.disk != null ? each.value.preserved_state.disk : {}
        iterator = disk
        content {
          device_name = disk.key
          source      = disk.value.source
          mode        = disk.value.read_only ? "READ_ONLY" : "READ_WRITE"
          delete_rule = disk.value.delete_on_instance_deletion ? "ON_PERMANENT_INSTANCE_DELETION" : "NEVER"
        }
      }
    }
  }
}



##############################################################################################################################################


resource "google_compute_region_per_instance_config" "instance_config" {
  for_each                         = var.stateful_config == {} ? {} : var.is_regional ? var.stateful_config : {}
  name                             = each.key
  region_instance_group_manager    = try(google_compute_region_instance_group_manager.instance_group.0.id, null)
  region                           = var.region
  project                          = var.project_id
  minimal_action                   = each.value.minimal_action
  most_disruptive_allowed_action   = each.value.most_disruptive_allowed_action
  remove_instance_state_on_destroy = each.value.remove_instance_state_on_destroy

  dynamic "preserved_state" {
    for_each = each.value.preserved_state != null ? [each.value.preserved_state] : []
    iterator = state
    content {
      metadata = state.value.metadata
      dynamic "disk" {
        for_each = state.value.disk != null ? state.value.disk : {}
        iterator = disk
        content {
          device_name = disk.key
          source      = disk.value.source
          mode        = disk.value.read_only ? "READ_ONLY" : "READ_WRITE"
          delete_rule = disk.value.delete_on_instance_deletion ? "ON_PERMANENT_INSTANCE_DELETION" : "NEVER"
        }
      }
    }
  }
}