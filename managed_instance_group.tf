resource "google_compute_instance_group_manager" "instance_group" { # Zonal Instance Group

  #############
  ## General ##
  #############

  count              = var.is_regional ? 0 : 1
  project            = var.project_id
  name               = var.name
  base_instance_name = var.name
  description        = var.description
  zone               = var.zone

  # dynamic "all_instances_config" { # Beta property. Remove comments when turn to GA
  #   for_each = (var.labels != null && var.metadata != null) ? [""] : []
  #   labels = try(var.labels, null)
  #   metadata = try(var.metadata, null)
  # }

  dynamic "version" {
    for_each = var.versions
    content {
      name              = version.key
      instance_template = var.instance_template
      dynamic "target_size" {
        for_each = version.value.target_size != null ? [""] : []
        content {
          fixed   = version.value.target_size.fixed
          percent = version.value.target_size.percent
        }
      }
    }
  }

  target_size               = var.target_size
  target_pools              = var.target_pools
  wait_for_instances        = try(var.wait_for_instances.enabled, null)
  wait_for_instances_status = try(var.wait_for_instances.status, null)

  ############################
  ## Stateful Configuration ##
  ############################

  dynamic "stateful_disk" {
    for_each = {
      for disk in var.stateful_disks : disk.device_name => disk # This is how to loop for_each through a list of objects 
    }
    content {
      device_name = each.value.device_name
      delete_rule = each.value.delete_rule
    }
  }

  #################
  ## Autohealing ##
  #################

  dynamic "auto_healing_policies" {
    for_each = var.auto_healing_policy != null ? [""] : []
    content {
      health_check      = local.health_check
      initial_delay_sec = var.auto_healing_policy.initial_delay_sec
    }
  }

  #################
  ## Portmapping ##
  #################

  dynamic "named_port" {
    for_each = var.named_port != null ? var.named_port : {}
    content {
      name = each.key
      port = each.value
    }
  }

  ###########################
  ## Update Configuration ##
  ###########################

  dynamic "update_policy" {
    for_each = var.update_policy != null ? [""] : []
    content {
      minimal_action                 = var.update_policy.minimal_action
      most_disruptive_allowed_action = var.update_policy.most_disruptive_allowed_action
      type                           = var.update_policy.type
      max_surge_fixed                = var.update_policy.max_surge.fixed
      max_surge_percent              = var.update_policy.max_surge.percent
      # max_unavailable_fixed          = var.update_policy.max_unavailable.fixed
      # max_unavailable_percent        = var.update_policy.max_unavailable.percent
      max_unavailable_fixed   = var.update_policy.max_unavailable.fixed
      max_unavailable_percent = var.update_policy.max_unavailable.percent
      replacement_method      = var.update_policy.replacement_method
    }
  }

  ############################
  ## Advanced Configuration ##
  ############################

  list_managed_instances_results = var.list_managed_instances_results
}

##############################################################################################################################################

resource "google_compute_region_instance_group_manager" "instance_group" { #Regional Instance Group

  #############
  ## General ##
  #############

  count                            = var.is_regional ? 1 : 0
  project                          = var.project_id
  name                             = var.name
  base_instance_name               = var.name
  description                      = var.description
  region                           = var.region
  distribution_policy_zones        = try(var.distribution_zones, null)
  distribution_policy_target_shape = try(var.distribution_target_shape, null)


  # dynamic "all_instances_config" { # Beta property. Remove comments when turn to GA
  #   for_each = (var.labels != null && var.metadata != null) ? [""] : []
  #   labels = try(var.labels, null)
  #   metadata = try(var.metadata, null)
  # }

  dynamic "version" {
    for_each = var.versions
    content {
      name              = version.key
      instance_template = var.instance_template
      dynamic "target_size" {
        for_each = version.value.target_size != null ? [""] : []
        content {
          fixed   = version.value.target_size.fixed
          percent = version.value.target_size.percent
        }
      }
    }
  }

  target_size               = var.target_size
  target_pools              = var.target_pools
  wait_for_instances        = try(var.wait_for_instances.enabled, null)
  wait_for_instances_status = try(var.wait_for_instances.status, null)

  ############################
  ## Stateful Configuration ##
  ############################

  dynamic "stateful_disk" {
    for_each = {
      for disk in var.stateful_disks : disk.device_name => disk # This is how to loop for_each through a list of objects 
    }
    iterator = config
    content {
      # device_name = each.value.device_name
      device_name = config.value.device_name
      delete_rule = config.value.delete_rule
      # delete_rule = each.value.delete_rule
    }
  }

  #################
  ## Autohealing ##
  #################

  dynamic "auto_healing_policies" {
    for_each = var.auto_healing_policy != null ? [""] : []
    content {
      health_check      = local.health_check
      initial_delay_sec = var.auto_healing_policy.initial_delay_sec
    }
  }

  #################
  ## Portmapping ##
  #################

  dynamic "named_port" {
    for_each = var.named_port != null ? var.named_port : {}
    content {
      name = named_port.key
      port = named_port.value
    }
  }

  ###########################
  ## Update Configuration ##
  ###########################

  dynamic "update_policy" {
    for_each = var.update_policy != null ? [""] : []
    content {
      minimal_action                 = var.update_policy.minimal_action
      most_disruptive_allowed_action = var.update_policy.most_disruptive_allowed_action
      type                           = var.update_policy.type
      # max_surge_fixed = var.update_policy.max_surge.fixed
      max_surge_percent            = var.update_policy.max_surge.percent
      max_unavailable_fixed        = var.update_policy.max_unavailable.fixed
      max_unavailable_percent      = var.update_policy.max_unavailable.percent
      replacement_method           = var.update_policy.replacement_method
      instance_redistribution_type = var.update_policy.instance_redistribution_type
      # replacement_method = var.update_policy.max_unavailable.replacement_method
      # instance_redistribution_type = var.update_policy.max_unavailable.instance_redistribution_type
    }
  }

  ############################
  ## Advanced Configuration ##
  ############################

  list_managed_instances_results = var.list_managed_instances_results


}



