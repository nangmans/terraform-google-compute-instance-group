/**
 * Copyright 2023 Google LLC
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

module "instance_group" {
  source = "../.."
  ### General ### 
  project_id           = var.project_id
  name                 = var.name
  base_instance_name   = var.base_instance_name
  description          = var.description
  default_version_name = var.default_version_name
  instance_template    = var.instance_template
  versions             = var.versions
  target_size          = var.target_size
  target_pools         = var.target_pools
  wait_for_instances   = var.wait_for_instances

  ### Location ### 
  is_regional               = var.is_regional
  zone                      = var.zone
  region                    = var.region
  distribution_zones        = var.distribution_zones
  distribution_target_shape = var.distribution_target_shape

  ### Autoscaling ### 
  autoscaling_config = { # AutoScaling Config는 여러개 사용 가능
  cooldown_period = 300 # 60s = 1m 
  max_replicas    = 4
  # scaling_schedule = { # Autoscaling에 대한 Scheduling 설정
  #   "key" = {
  #     cron_schedule         = "0 7 * * MON-FRI" # ex) "0 7 * * MON-FRI"(Cron 표현식을 사용한 스케줄 설정 가능)
  #     description           = "dev cronjob"     # Scheduling에 대한 설명 
  #     disabled              = false             # Sceduling 예약을 True로 설정하게 되면 Scaling 예약이 적용되지 않음
  #     duration_sec          = 300               # Scaling 예약이 실행될 시간, 최소값은 300초(5분)임
  #     min_required_replicas = 2                 # Auto Scaling 예약에 따른 최소 인스턴스 증가되는 값 ex) 2 
  #     time_zone             = "Asia/Seoul"      # Tz_database를 기준으로 설정됨
  #   }
  # }
  metric = {
    # cloud_monitoring_metric = {                                # filter를 거는것은 Beta로 지원(추 후 GA될 경우, Metric Filter 기입 필요)
    #   name = "compute.googleapis.com/instance/cpu/utilization" # ex) "compute.googleapis.com/*","agent.googleapis.com/*"
    #   target = 0.1     # Rate ( 0 ~ 100 ) ex) 10=10%
    #   type   = "GAUGE" # ex) "GAUGE","DELTA_PER_SECOND","DELTA_PER_MINUTE"
    # }
    cpu_utilization = {
      is_predictive = false # bool(true/false) CPU Metric 기반의 예측 자동 크기 조정이 활성화 되었는지 여부
      target        = 0.8   # Rate ( 0 ~ 1 ) ex) 0.01=1%
    }
    # load_balancing_utilization = {
    #   target = 0.8    # Rate ( 0 ~ 1 ) ex) 0.01=1%
    # } 
  }
  min_replicas = 2
  mode         = "ON" # ex) "ON"(Scale int & Out),OFF(No Scale),ONLY_UP(Only Scale Out)
  name         = "prj-sandbox-d-scaler-config-a"
  scale_in_control = {
    max_scaled_in_replicas = {
      fixed = 4
      # percent = 1
    }
    time_window_sec = 60
  }
  } 

  ### Autohealing ###
  auto_healing_policy = {
  health_check      = module.instance_group_a.health_check.id  # URL malformed.. hc의 Self_Link 사용이 필요해보임
  initial_delay_sec = 300
  } 

  health_check_config = var.health_check_config

  ### Port Mapping ###
  named_port = var.named_port

  ### Update Configuration ### 
  update_policy = var.update_policy

  ### Advanced Configuration ###
  list_managed_instances_results = var.list_managed_instances_results

  ### Stateful Configuration ###
  stateful_disks  = var.stateful_disks
  #stateful_config = var.stateful_config


  ### Unmanaged Instance Group Configuration ###
  # instances = var.instances
  # network = var.network
}

module "instance_group_b" {
  source = "../.."
  ### General ### 
  project_id           = var.project_id
  name                 = "prj-devops-sandbox-d-mig-b"
  base_instance_name   = "prj-devops-sandbox-d-mig-b"
  description          = var.description
  default_version_name = var.default_version_name
  instance_template    = "projects/prj-sandbox-ifd-9000/global/instanceTemplates/${var.instance_template_b}"
  # versions             = {
  #   "v0.0.1" = {
  #     instance_template = "projects/prj-sandbox-ifd-9000/global/instanceTemplates/${var.instance_template_b}"
  #   }
  # }
  target_size          = var.target_size
  target_pools         = var.target_pools
  wait_for_instances   = var.wait_for_instances

  ### Location ### 
  is_regional               = var.is_regional
  zone                      = var.zone
  region                    = var.region
  distribution_zones        = var.distribution_zones
  distribution_target_shape = var.distribution_target_shape

  ### Autoscaling ### 
  autoscaling_config = { # AutoScaling Config는 여러개 사용 가능
  cooldown_period = 300 # 60s = 1m 
  max_replicas    = 4
  # scaling_schedule = { # Autoscaling에 대한 Scheduling 설정
  #   "key" = {
  #     cron_schedule         = "0 7 * * MON-FRI" # ex) "0 7 * * MON-FRI"(Cron 표현식을 사용한 스케줄 설정 가능)
  #     description           = "dev cronjob"     # Scheduling에 대한 설명 
  #     disabled              = false             # Sceduling 예약을 True로 설정하게 되면 Scaling 예약이 적용되지 않음
  #     duration_sec          = 300               # Scaling 예약이 실행될 시간, 최소값은 300초(5분)임
  #     min_required_replicas = 2                 # Auto Scaling 예약에 따른 최소 인스턴스 증가되는 값 ex) 2 
  #     time_zone             = "Asia/Seoul"      # Tz_database를 기준으로 설정됨
  #   }
  # }
  metric = {
    # cloud_monitoring_metric = {                                # filter를 거는것은 Beta로 지원(추 후 GA될 경우, Metric Filter 기입 필요)
    #   name = "compute.googleapis.com/instance/cpu/utilization" # ex) "compute.googleapis.com/*","agent.googleapis.com/*"
    #   target = 0.1     # Rate ( 0 ~ 100 ) ex) 10=10%
    #   type   = "GAUGE" # ex) "GAUGE","DELTA_PER_SECOND","DELTA_PER_MINUTE"
    # }
    cpu_utilization = {
      is_predictive = false # bool(true/false) CPU Metric 기반의 예측 자동 크기 조정이 활성화 되었는지 여부
      target        = 0.8   # Rate ( 0 ~ 1 ) ex) 0.01=1%
    }
    # load_balancing_utilization = {
    #   target = 0.8    # Rate ( 0 ~ 1 ) ex) 0.01=1%
    # } 
  }
  min_replicas = 2
  mode         = "ON" # ex) "ON"(Scale int & Out),OFF(No Scale),ONLY_UP(Only Scale Out)
  name         = "prj-sandbox-d-scaler-config-b"
  scale_in_control = {
    max_scaled_in_replicas = {
      fixed = 4
      # percent = 1
    }
    time_window_sec = 60
  }
  } 
  

  ### Autohealing ###
  auto_healing_policy = {
  health_check      = module.instance_group_b.health_check.id  # URL malformed.. hc의 Self_Link 사용이 필요해보임
  initial_delay_sec = 300
  } 
  health_check_config = var.health_check_config

  ### Port Mapping ###
  named_port = var.named_port

  ### Update Configuration ### 
  update_policy = var.update_policy

  ### Advanced Configuration ###
  list_managed_instances_results = var.list_managed_instances_results

  ### Stateful Configuration ###
  stateful_disks  = var.stateful_disks
  #stateful_config = var.stateful_config

  ### Unmanaged Instance Group Configuration ###
  # instances = var.instances
  # network = var.network
}