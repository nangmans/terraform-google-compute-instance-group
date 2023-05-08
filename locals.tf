locals {
  health_check = (
    try(var.auto_healing_policy.health_check, null) == null
    ? try(google_compute_health_check.default.0.self_link, null)
    : try(var.auto_healing_policy.health_check, null)
  )
  hc       = var.health_check_config
  http_hc  = try(local.hc.http_health_check, null)
  https_hc = try(local.hc.https_health_check, null)
  http2_hc = try(local.hc.http2_health_check, null)
  tcp_hc   = try(local.hc.tcp_health_check, null)
  ssl_hc   = try(local.hc.ssl_health_check, null)
  grpc_hc  = try(local.hc.grpc_health_check, null)

  ac          = var.autoscaling_config
  scale_in_ac = try(var.autoscaling_config.scale_in_control, null)
  metric_ac = try(var.autoscaling_config.metric, null)
  schedule_ac = try(var.autoscaling_config.scaling_schedule.scaling_schedule, null)

  module_name    = "terraform-google-compute-instance-group"
  module_version = "v0.0.1"
}
