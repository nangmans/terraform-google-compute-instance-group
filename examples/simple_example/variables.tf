/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#############
## General ##
#############

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "name" {
  description = "The name of the instance group to create"
  type        = string
}

variable "base_instance_name" {
  description = "The base instance name to use for instances in this group"
  type        = string
}

variable "description" {
  description = "An optional textual description of the instance group manager"
  type        = string
  default     = ""
}

# variable "labels" { # Used for "all_instances_config" block. Remove comments when "all_instances_config" turn to GA
#   description = "The label to attach to the instances"
#   type = map(string)
#   default = null
# }

# variable "metadata" { # Used for "all_instances_config" block. Remove comments when "all_instances_config" turn to GA
#   description = "Metadata key/value pairs to make available from within the instance"
#   type = map(string)
#   default = null
# }

variable "default_version_name" {
  description = "Name used for the default version"
  type        = string
  default     = "default"
}

variable "instance_template" {
  description = "Instance template for the default version"
  type        = string
}

variable "versions" {
  description = "Additional application versions managed by this instance group"
  type = map(object({
    target_size = optional(object({
      fixed   = optional(number)
      percent = optional(number)
    }))
  }))
  default = {}
  validation {
    condition = (
      (try(var.versions.target_size.fixed, null) == null ? 0 : 1) +
      (try(var.versions.target_size.percent, null) == null ? 0 : 1) <= 1
    )
    error_message = "only one of fixed or percent variable can be used"
  }
}

variable "target_size" {
  description = "Group target size, leave null when using an autoscaler"
  type        = number
  default     = null
}

variable "target_pools" {
  description = "The full URL of all target pools to which new instances in the group are added"
  type        = list(string)
  default     = []
}

variable "wait_for_instances" {
  description = "Whether to wait for all instances to be created/updated before returning"
  type = object({
    enabled = bool
    status  = optional(string) # STABLE , UPDATED
  })
  default = null
}

##############
## Location ##
##############

variable "is_regional" {
  description = "Whether instance group is regional or not"
  type        = bool
  default     = false
}

variable "zone" {
  description = "The zone where zonal instance group being created"
  type        = string
}

variable "region" { # "Regional only"
  description = "The region where regional instance group being created"
  type        = string
  default     = "asia-northeast3"
}

variable "distribution_zones" { # "Regional only"
  description = "The distribution policy for this managed instance group"
  type        = list(string)
  default     = null
}

variable "distribution_target_shape" { # "Regional only"
  description = " The shape to which the group converges either proactively or on resize events"
  type        = string # EVENT(default) , BALANCED , ANY , ANY_SINGLE_ZONE
  default     = null
}

#################
## Autoscaling ##
#################

variable "autoscaling_config" {
  description = "Autoscaling configurations for statelss managed instance group"
  type = object({
    name            = string
    mode            = optional(string) # ON(default) , OFF, ONLY_UP
    max_replicas    = number
    min_replicas    = number
    cooldown_period = optional(number) # default is 60
    scale_in_control = optional(object({
      time_window_sec = optional(number)
      max_scaled_in_replicas = optional(object({
        fixed   = optional(number)
        percent = optional(number)
      }))
    }))
    metric = optional(object({
      cpu_utilization = optional(object({
        target        = number         # 0 ~ 1 default is 0.6
        is_predictive = optional(bool) # NONE(default) , OPTIMIZE_AVAILABILITY
      }))
      load_balancing_utilization = optional(object({
        target = number # 0 ~ 1 default is 0.8
      }))
      cloud_monitoring_metric = optional(object({
        name   = string
        target = optional(number)
        type   = optional(string) # GAUGE , DELTA_PER_SECOND , DELTA_PER_MINUTE
      }))
    }))
    scaling_schedule = optional(map(object({
      min_required_replicas = number
      cron_schedule         = string
      description           = optional(string)
      time_zone             = optional(string)
      duration_sec          = number
      disabled              = optional(bool)
    })))
  })
  default = null
}


############################
## Stateful Configuration ##
############################

variable "stateful_disks" {
  description = "Disks created on the instances that will be preserved on instance delete, update, etc"
  type = list(object({
    device_name = string
    delete_rule = optional(string) # NEVER , ON_PERMANENT_INSTANCE_DELETION
  }))
  default = []
}

variable "stateful_config" {
  description = "A config defined for a single managed instance that belongs to an instance group manager"
  type = map(object({
    minimal_action                   = optional(string) # REPLACE , RESTART , REFRESH , NONE(default)
    most_disruptive_allowed_action   = optional(string) # REPLACE(default) , RESTART , REFRESH , NONE
    remove_instance_state_on_destroy = optional(bool)
    preserved_state = optional(object({
      metadata = optional(map(string))
      disk = optional(map(object({
        source                      = string
        read_only                   = optional(bool) # READ_WRITE(default) , READ_ONLY
        delete_on_instance_deletion = optional(bool) # NEVER(default) , ON_PERMANENT_INSTANCE_DELETION
      })))
    }))
  }))
  default  = {}
  nullable = false
}

#################
## Autohealing ##
#################

variable "auto_healing_policy" {
  description = "The autohealing policy for this managed instance group"
  type = object({
    health_check      = optional(string)
    initial_delay_sec = number
  })
  default = null
}

variable "health_check_config" {
  description = "Optional auto-created health check configuration, use the output self-link to set it in the auto healing policy. Refer to examples for usage"
  type = object({
    description         = optional(string)
    check_interval_sec  = optional(number)
    healthy_threshold   = optional(number)
    timeout_sec         = optional(number)
    unhealthy_threshold = optional(number)
    enable_logging      = optional(bool)
    http_health_check = optional(object({
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    https_health_check = optional(object({
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    http2_health_check = optional(object({
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    tcp_health_check = optional(object({
      request            = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    ssl_health_check = optional(object({
      request            = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    grpc_health_check = optional(object({
      grpc_service_name  = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
  })
  default = null
  validation {
    condition = (
      (try(var.health_check_config.http_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.https_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.http2_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.tcp_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.ssl_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.grpc_health_check, null) != null ? 1 : 0) <= 1
    )
    error_message = "Only one health check type can be configured at a time."
  }
}

#################
## Portmapping ##
#################

variable "named_port" {
  description = "The named port configuration"
  type        = map(number)
  default     = null
}
# variable "named_port" {
#   description = "The named port configuration"
#   type = map(object({
#     name = string
#     port = string
#   }))
#   default = null
# }
###########################
## Update Configuration ##
###########################

variable "update_policy" {
  description = "The update policy for this managed instance group"
  type = object({
    minimal_action                 = string           # REFRESH , RESTART , REPLACE 
    most_disruptive_allowed_action = optional(string) # NONE , REFRESH , RESTART , REPLACE
    type                           = string           # PROACTIVE , OPPORTUNISTIC
    max_surge = optional(object({
      fixed   = optional(number, 1) # Conflicts with percent
      percent = optional(number)    # Conflicts with fixed
    }))
    max_unavailable = optional(object({
      fixed   = optional(number, 1) # Conflicts with percent
      percent = optional(number)    # Conflicts with fixed
    }))
    replacement_method           = optional(string) # RECREATE , SUBSTITUTE
    instance_redistribution_type = optional(string) # PROACTIVE , NONE "Regional only"
  })
  default = null

  # validation {
  #   condition = 
  #   error_message = 
  # }
}

############################
## Advanced Configuration ##
############################

variable "list_managed_instances_results" {
  description = "Pagination behavior of the listManagedInstances API method for this managed instance group"
  type        = string
  default     = "asia-northeast3"
}

variable "distribution_zones" { # "Regional only"
  description = "The distribution policy for this managed instance group"
  type        = list(string)
  default     = null
}

variable "distribution_target_shape" { # "Regional only"
  description = " The shape to which the group converges either proactively or on resize events"
  type        = string # EVENT(default) , BALANCED , ANY , ANY_SINGLE_ZONE
  default     = null
}

#################
## Autoscaling ##
#################

variable "autoscaling_config" {
  description = "Autoscaling configurations for statelss managed instance group"
  type = object({
    name            = string
    mode            = optional(string) # ON(default) , OFF, ONLY_UP
    max_replicas    = number
    min_replicas    = number
    cooldown_period = optional(number) # default is 60
    scale_in_control = optional(object({
      time_window_sec = optional(number)
      max_scaled_in_replicas = optional(object({
        fixed   = optional(number)
        percent = optional(number)
      }))
    }))
    metric = optional(object({
      cpu_utilization = optional(object({
        target        = number         # 0 ~ 1 default is 0.6
        is_predictive = optional(bool) # NONE(default) , OPTIMIZE_AVAILABILITY
      }))
      load_balancing_utilization = optional(object({
        target = number # 0 ~ 1 default is 0.8
      }))
      cloud_monitoring_metric = optional(object({
        name   = string
        target = optional(number)
        type   = optional(string) # GAUGE , DELTA_PER_SECOND , DELTA_PER_MINUTE
      }))
    }))
    scaling_schedule = optional(map(object({
      min_required_replicas = number
      cron_schedule         = string
      description           = optional(string)
      time_zone             = optional(string)
      duration_sec          = number
      disabled              = optional(bool)
    })))
  })
  default = null
}


############################
## Stateful Configuration ##
############################

variable "stateful_disks" {
  description = "Disks created on the instances that will be preserved on instance delete, update, etc"
  type = list(object({
    device_name = string
    delete_rule = optional(string) # NEVER , ON_PERMANENT_INSTANCE_DELETION
  }))
  default = []
}

variable "stateful_config" {
  description = "A config defined for a single managed instance that belongs to an instance group manager"
  type = map(object({
    minimal_action                   = optional(string) # REPLACE , RESTART , REFRESH , NONE(default)
    most_disruptive_allowed_action   = optional(string) # REPLACE(default) , RESTART , REFRESH , NONE
    remove_instance_state_on_destroy = optional(bool)
    preserved_state = optional(object({
      metadata = optional(map(string))
      disk = optional(map(object({
        source                      = string
        read_only                   = optional(bool) # READ_WRITE(default) , READ_ONLY
        delete_on_instance_deletion = optional(bool) # NEVER(default) , ON_PERMANENT_INSTANCE_DELETION
      })))
    }))
  }))
  default  = {}
  nullable = false
}

#################
## Autohealing ##
#################

variable "auto_healing_policy" {
  description = "The autohealing policy for this managed instance group"
  type = object({
    health_check      = optional(string)
    initial_delay_sec = number
  })
  default = null
}

variable "health_check_config" {
  description = "Optional auto-created health check configuration, use the output self-link to set it in the auto healing policy. Refer to examples for usage"
  type = object({
    description         = optional(string)
    check_interval_sec  = optional(number)
    healthy_threshold   = optional(number)
    timeout_sec         = optional(number)
    unhealthy_threshold = optional(number)
    enable_logging      = optional(bool)
    http_health_check = optional(object({
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    https_health_check = optional(object({
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    http2_health_check = optional(object({
      host               = optional(string)
      request_path       = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    tcp_health_check = optional(object({
      request            = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    ssl_health_check = optional(object({
      request            = optional(string)
      response           = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      proxy_header       = optional(string) # NONE , PROXY_V1
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
    grpc_health_check = optional(object({
      grpc_service_name  = optional(string)
      port               = optional(number)
      port_name          = optional(string)
      port_specification = optional(string) # USE_FIXED_PORT , USE_NAMED_PORT , USE_SERVING_PORT
    }))
  })
  default = null
  validation {
    condition = (
      (try(var.health_check_config.http_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.https_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.http2_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.tcp_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.ssl_health_check, null) != null ? 1 : 0) +
      (try(var.health_check_config.grpc_health_check, null) != null ? 1 : 0) <= 1
    )
    error_message = "Only one health check type can be configured at a time."
  }
}

#################
## Portmapping ##
#################

variable "named_port" {
  description = "The named port configuration"
  type        = map(number)
  default     = null
}
# variable "named_port" {
#   description = "The named port configuration"
#   type = map(object({
#     name = string
#     port = string
#   }))
#   default = null
# }
###########################
## Update Configuration ##
###########################

variable "update_policy" {
  description = "The update policy for this managed instance group"
  type = object({
    minimal_action                 = string           # REFRESH , RESTART , REPLACE 
    most_disruptive_allowed_action = optional(string) # NONE , REFRESH , RESTART , REPLACE
    type                           = string           # PROACTIVE , OPPORTUNISTIC
    max_surge = optional(object({
      fixed   = optional(number, 1) # Conflicts with percent
      percent = optional(number)    # Conflicts with fixed
    }))
    max_unavailable = optional(object({
      fixed   = optional(number, 1) # Conflicts with percent
      percent = optional(number)    # Conflicts with fixed
    }))
    replacement_method           = optional(string) # RECREATE , SUBSTITUTE
    instance_redistribution_type = optional(string) # PROACTIVE , NONE "Regional only"
  })
  default = null

  # validation {
  #   condition = 
  #   error_message = 
  # }
}

############################
## Advanced Configuration ##
############################

variable "list_managed_instances_results" {
  description = "Pagination behavior of the listManagedInstances API method for this managed instance group"
  type        = string
  default     = "PAGELESS"
}

############################################
## Unmanaged Instance Group Configuration ##
############################################

variable "instances" {
  description = "The list of instances in the group, in self_link format"
  type        = list(string)
  default     = null
}

variable "network" {
  description = "The URL of the network the instance group is in"
  type        = string
  default     = null
}