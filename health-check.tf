resource "google_compute_health_check" "default" {
  count               = local.hc != null ? 1 : 0
  name                = "hc-${var.name}"
  project             = var.project_id
  description         = local.hc.description
  check_interval_sec  = local.hc.check_interval_sec
  healthy_threshold   = local.hc.healthy_threshold
  timeout_sec         = local.hc.timeout_sec
  unhealthy_threshold = local.hc.unhealthy_threshold
  dynamic "log_config" {
    for_each = try(local.hc.enable_logging, null) == true ? [""] : []
    content {
      enable = true
    }
  }
  dynamic "http_health_check" {
    for_each = local.http_hc != null ? [""] : []
    content {
      host               = local.http_hc.host
      request_path       = local.http_hc.request_path
      response           = local.http_hc.response
      port               = local.http_hc.port
      port_name          = local.http_hc.port_name
      proxy_header       = local.http_hc.proxy_header
      port_specification = local.http_hc.port_specification
    }
  }
  dynamic "https_health_check" {
    for_each = local.https_hc != null ? [""] : []
    content {
      host               = local.https_hc.host
      request_path       = local.https_hc.request_path
      response           = local.https_hc.response
      port               = local.https_hc.port
      port_name          = local.htts_hc.port_name
      proxy_header       = local.https_hc.proxy_header
      port_specification = local.https_hc.port_specification
    }
  }
  dynamic "http2_health_check" {
    for_each = local.http2_hc != null ? [""] : []
    content {
      host               = local.http2_hc.host
      request_path       = local.http2_hc.request_path
      response           = local.http2_hc.response
      port               = local.http2_hc.port
      port_name          = local.http2_hc.port_name
      proxy_header       = local.http2_hc.proxy_header
      port_specification = local.http2_hc.port_specification
    }
  }
  dynamic "tcp_health_check" {
    for_each = local.tcp_hc != null ? [""] : []
    content {
      request            = local.tcp_hc.request
      response           = local.tcp_hc.response
      port               = local.tcp_hc.port
      port_name          = local.tcp_hc.port_name
      proxy_header       = local.tcp_hc.proxy_header
      port_specification = local.tcp_hc.port_specification
    }
  }
  dynamic "ssl_health_check" {
    for_each = local.ssl_hc != null ? [""] : []
    content {
      request            = local.ssl_hc.request
      response           = local.ssl_hc.response
      port               = local.ssl_hc.port
      port_name          = local.ssl_hc.port_name
      proxy_header       = local.ssl_hc.proxy_header
      port_specification = local.ssl_hc.port_specification
    }
  }
  dynamic "grpc_health_check" {
    for_each = local.grpc_hc != null ? [""] : []
    content {
      grpc_service_name  = local.grpc_hc.grpc_service_name
      port               = local.grpc_hc.port
      port_name          = local.grpc_hc.port_name
      port_specification = local.grpc_hc.port_specification
    }
  }
}