resource "google_compute_autoscaler" "autoscaler" {
  count       = (local.ac == null || var.is_regional) ? 0 : 1
  name        = local.ac.name
  zone        = var.zone
  project     = var.project_id
  description = "Terraform created autoscaler by ${var.name}"
  target      = google_compute_instance_group_manager.instance_group.0.id
  autoscaling_policy {
    mode            = local.ac.mode
    max_replicas    = local.ac.max_replicas
    min_replicas    = local.ac.min_replicas
    cooldown_period = local.ac.cooldown_period
    dynamic "scale_in_control" {
      for_each = local.scale_in_ac != null ? [""] : []
      content {
        time_window_sec = local.scale_in_ac.time_window_sec
        dynamic "max_scaled_in_replicas" {
          for_each = (
            local.scale_in_ac.max_scaled_in_replicas.fixed != null
            || local.scale_in_ac.max_scaled_in_replicas.percent != null
          ) ? [""] : []
          content {
            fixed   = local.scale_in_ac.max_scaled_in_replicas.fixed
            percent = local.scale_in_ac.max_scaled_in_replicas.percent
          }
        }
      }
    }
    dynamic "cpu_utilization" {
      for_each = local.metric_ac.cpu_utilization != null ? [""] : []
      content {
        target            = local.metric_ac.cpu_utilization.target
        predictive_method = local.metric_ac.cpu_utilization.is_predictive ? "OPTIMIZE_AVAILABILITY" : "NONE"
      }
    }
    dynamic "load_balancing_utilization" {
      for_each = local.metric_ac.load_balancing_utilization != null ? [""] : []
      content {
        target = local.metric_ac.load_balancing_utilization.target
      }
    }
    dynamic "metric" {
      for_each = local.metric_ac.cloud_monitoring_metric != null ? [""] : []
      content {
        name   = local.metric_ac.cloud_monitoring_metric.name
        target = local.metric_ac.cloud_monitoring_metric.target
        type   = local.metric_ac.cloud_monitoring_metric.type
      }
    }
    dynamic "scaling_schedules" {
      for_each = local.schedule_ac != null ? local.schedule_ac : {}
      content {
        name                  = each.key
        min_required_replicas = each.value.min_required_replicas
        schedule              = each.value.cron_schedule
        description           = each.value.description
        time_zone             = each.value.time_zone
        duration_sec          = each.value.duration_sec
        disabled              = each.value.disabled
      }
    }
  }
}

##############################################################################################################################################

resource "google_compute_region_autoscaler" "autoscaler" {
  count       = (local.ac != null && var.is_regional) ? 1 : 0
  name        = local.ac.name
  region      = var.region
  project     = var.project_id
  description = "Terraform created autoscaler by ${var.name}"
  target      = google_compute_region_instance_group_manager.instance_group.0.id
  autoscaling_policy {
    mode            = local.ac.mode
    max_replicas    = local.ac.max_replicas
    min_replicas    = local.ac.min_replicas
    cooldown_period = local.ac.cooldown_period
    dynamic "scale_in_control" {
      for_each = local.scale_in_ac != null ? [""] : []
      content {
        time_window_sec = local.scale_in_ac.time_window_sec
        dynamic "max_scaled_in_replicas" {
          for_each = (
            local.scale_in_ac.max_scaled_in_replicas.fixed != null
            || local.scale_in_ac.max_scaled_in_replicas.percent != null
          ) ? [""] : []
          content {
            fixed   = local.scale_in_ac.max_scaled_in_replicas.fixed
            percent = local.scale_in_ac.max_scaled_in_replicas.percent
          }
        }
      }
    }
    dynamic "cpu_utilization" {
      for_each = local.metric_ac.cpu_utilization != null ? [""] : []
      content {
        target            = local.metric_ac.cpu_utilization.target
        predictive_method = local.metric_ac.cpu_utilization.is_predictive ? "OPTIMIZE_AVAILABILITY" : "NONE"
      }
    }
    dynamic "load_balancing_utilization" {
      for_each = local.metric_ac.load_balancing_utilization != null ? [""] : []
      content {
        target = local.metric_ac.load_balancing_utilization.target
      }
    }
    dynamic "metric" {
      for_each = local.metric_ac.cloud_monitoring_metric != null ? [""] : []
      content {
        name   = local.metric_ac.cloud_monitoring_metric.name
        target = local.metric_ac.cloud_monitoring_metric.target
        type   = local.metric_ac.cloud_monitoring_metric.type
      }
    }
    dynamic "scaling_schedules" {
      for_each = local.schedule_ac != null ? local.schedule_ac : {}
      iterator = config
      content {
        name                  = config.key
        min_required_replicas = config.value.min_required_replicas
        schedule              = config.value.cron_schedule
        description           = config.value.description
        time_zone             = config.value.time_zone
        duration_sec          = config.value.duration_sec
        disabled              = config.value.disabled
      }
    }
  }
}