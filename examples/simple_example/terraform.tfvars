### General ### 
project_id           = "klint-gyeongsik-dev"
name                 = "prj-dev-gyeongsik-mig-manager" # Instace Group Manager Name
base_instance_name   = "prj-dev-gyeongsik-mig"         # Instance Group에 사용할 Base Instance Name
description          = "cloud-devops demo instance group module prove"
default_version_name = "version-v001" #version Name 명시, 인스턴스 템플릿 v0.01, ... etc 
# instance_template    = "gyeongsik-gce-template" # Instance Template Name
instance_template = "projects/klint-gyeongsik-dev/global/instanceTemplates/gyeongsik-gce-template"
versions = {
  "key" = {
    # AutoScaling이 걸리지 않는 "BALANCED", "ANY", "ANY_SINGLE_ZONE" 일때 사용하는 Variable
    target_size = {
      # fixed   = 2
      # percent = 20
    }
  }
}
# target_size = 2 # "BALANCED", "ANY" Target_Shape 사용시 필요 ( Instance 개수 )
target_pools = [
  # "asia-northeast3-a/gyeongsik-dev-1",
  # "asia-northeast3-b/gyeongsik-dev-2",
] # UIG에서 사용하는것으로 추정, Target Instance 지정시 target_pool에 할당되는것으로 보여짐

wait_for_instances = { # 모든 인스턴스가 생성/업데이트 될때까지 기다리는것에 대한 여부, True로 설정되어 있고 작업이 성공하지 못하면 Terraform은 시간 초과할때까지 계속 시도
  enabled = false
  status  = "UPDATED" # ex) "STABLE","UPDATED"
}

### Location ### 
is_regional = true # Regional로 할지 Zonal로 할지 선택하는 변수
# zone = "asia-northeast3-a" # Zonal로 생성시 사용하는 변수
# region = "asia-northeast3" # Regional에서만 사용할 수 있는 변수
zone = "asia-northeast3-b"
distribution_zones = [
  # Regional 에서만 사용할수 있는 변수(Zone 선택)
  # Null값으로 넣으면 전체 Zone 다 선택됨
  "asia-northeast3-a",
  "asia-northeast3-b",
  "asia-northeast3-c",
]
distribution_target_shape = "EVEN" # ex) "EVEN"(Autoscaling_Config 필수사용),"BALANCED","ANY","ANY_SINGLE_ZONE"(AutoScaling_Config 사용 안함)

### Auto Scaling ### 
autoscaling_config = { # AutoScaling Config는 여러개 사용 가능
  cooldown_period = 600
  max_replicas    = 4
  scaling_schedule = { # Autoscaling에 대한 Scheduling 설정
    "key" = {
      cron_schedule         = "0 7 * * MON-FRI" # ex) "0 7 * * MON-FRI"(Cron 표현식을 사용한 스케줄 설정 가능)
      description           = "dev cronjob"     # Scheduling에 대한 설명 
      disabled              = false             # Sceduling 예약을 True로 설정하게 되면 Scaling 예약이 적용되지 않음
      duration_sec          = 300               # Scaling 예약이 실행될 시간, 최소값은 300초(5분)임
      min_required_replicas = 2                 # Auto Scaling 예약에 따른 최소 인스턴스 증가되는 값 ex) 2 
      time_zone             = "Asia/Seoul"      # Tz_database를 기준으로 설정됨
    }
  }
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
  name         = "gyeongsik-demo-scaler-config"
  scale_in_control = {
    max_scaled_in_replicas = {
      fixed = 4
      # percent = 1
    }
    time_window_sec = 60
  }
}

## Stateful Configuration ##
# stateful_disks = [{
#   delete_rule = "NEVER" # ex) "NEVER" , "ON_PERMANENT_INSTANCE_DELETION"
#   device_name = "dev-demo"
# }]

# stateful_config = {
#   "key" = {
#     minimal_action                 = "REPLACE" # ex) "REPLACE" , "RESTART" , "REFRESH" , NONE(default)
#     most_disruptive_allowed_action = "REPLACE" # ex) "REPLACE"(default) , "RESTART" , "REFRESH" , NONE
#     preserved_state = {
#       disk = {
#         delete_on_instance_deletion = false
#         device_name                 = "gyeongsik-dev"
#         read_only                   = false # ex) READ_WRITE(default), READ_ONLY
#         source                      = "value"
#       }
#       metadata = {
#         "enable-oslogin-2fa" = true,
#         "enable-oslogin"     = true,
#       }
#     }
#     remove_instance_state_on_destroy = false
#   }
# }

### Authhealing(Health Check)###

auto_healing_policy = {
  health_check      = "projects/klint-gyeongsik-dev/global/healthChecks/hc-prj-dev-gyeongsik-mig-manager" # URL malformed.. hc의 Self_Link 사용이 필요해보임
  initial_delay_sec = 300
}

health_check_config = {
  description    = "health Check Config(http)"
  enable_logging = true
  #   grpc_health_check = {
  #     grpc_service_name = "value"
  #     port = 1
  #     port_name = "value"
  #     port_specification = "value"
  #   }
  #   http2_health_check = {
  #     host = "value"
  #     port = 1
  #     port_name = "value"
  #     port_specification = "value"
  #     proxy_header = "value"
  #     request_path = "value"
  #     response = "value"
  #   }
  http_health_check = {
    host      = null # "value"
    port      = 80
    port_name = "http-80"
    # port_specification = "USE_SERVING_PORT" # PORT Specification 사용 안하고도 정상적으로 Health Check 만들어짐
    proxy_header = null # "value"
    request_path = "/"
    response     = null # "value"
  }
  #   https_health_check = {
  #     host = "value"
  #     port = 1
  #     port_name = "value"
  #     port_specification = "value"
  #     proxy_header = "value"
  #     request_path = "value"
  #     response = "value"
  #   }
  #   ssl_health_check = {
  #     port = 1
  #     port_name = "value"
  #     port_specification = "value"
  #     proxy_header = "value"
  #     request = "value"
  #     response = "value"
  #   }
  # tcp_health_check = {
  #   # port               = 80
  #   port_name          = "tcp-http-80"
  #   port_specification = "USE_NAMED_PORT" # ex) "USE_FIXED_PORT", "USE_NAMED_PORT","USE_SERVING_PORT"
  #   proxy_header       = "NONE"           # ex) "NONE", "PROXY_V1"
  #   request            = null              # request, reponse 특정 문자열을 통해 요청 응답 체크 가능
  #   response           = null
  # }
  check_interval_sec  = 60 # 각 프로버는 연결을 30초 마다 재시작
  timeout_sec         = 5  # State Probe 제한 시간
  healthy_threshold   = 2  # 정상 기준 
  unhealthy_threshold = 2  # 비정상 기준
  # 위 조건의 경우, 아래 예시로 작동
  # t=0: Probe A Start ---timeout_sec_add(5s)---> t=5 Probe A Stop --inteval_sec_add(30s)--> t=30: Probe B start ---> t=35: Probe B stop
}

### Port Mapping ###
named_port = {
  "http" = 80 # ex) "name" = port
}


### Update Configuration ###
# update_policy = {       # The update policy for this managed instance group
#   max_surge = {         # ex) 1 (업데이트 프로세스 중에 지정된 targetSize 이상으로 생성할 수 있는 최대 인스턴스 수)
#     # fixed = 5           # max_surge_percent와 Fixed 둘중 하나만 설정 가능, 둘 다 설정되지 않은 경우 기본값은 1
#     max_unavailable = { # ex) 1 (업데이트 프로세스 중에 사용할 수 없는 최대 인스턴스 수)
#       fixed                        = 2
#       # percent = 10 # max_unavailable_percent와 fixed 둘중 하나만 설정 가능, 둘 다 설정되지 않은 경우 기본값은 1
#     }
#     percent = 20
#   }
#   minimal_action                 = "REPLACE"   # ex) "REFRESH"(인스턴스를 중지하지않고 업데이트), "RESTART"(기존 인스턴스 재시작), "REPLACE"(대상 템플릿에서 인스턴스 삭제하고 재생성)
#   most_disruptive_allowed_action = "REPLACE"   # ex) "NONE"(모든 작업 금지), "REFRESH"(인스턴스 중지하지않고 업데이트),"RESTART"(기존 인스턴스 재시작),"REPLACE(인스턴스 삭제하고 재생성)"
#   type                           = "PROACTIVE" # ex) Update Process 유형 "PROACTIVE"(인스턴스 그룹 관리자가 대상 버전으로 인스턴스를 가져오기 위한 작업을 사전에 실행),"OPPORTUNISTIC"(작업이 사전에 실행되지 않지만 업데이트가 다른 작업의 일부로 수행 ex)크기 조정, 인스턴스 호출)
#   replacement_method = "SUBSTITUTE" # ex) "RECREATE"(인스턴스 이름 유지), "SUBSTITUTE"(인스턴스 이름을 임의의 새 값으로 변경)
#   instance_redistribution_type = "PROACTIVE" # ex) "PROACTIVE","NONE","Regional only"
# }
update_policy = {
  instance_redistribution_type = "PROACTIVE" #
  max_surge = {
    fixed = 2
    # percent = 20
  }
  max_unavailable = {
    fixed = 10
    # percent = 1
  }
  minimal_action                 = "REPLACE"
  most_disruptive_allowed_action = "REPLACE"
  replacement_method             = "SUBSTITUTE"
  type                           = "PROACTIVE"
}
### Advanced Configuration ###
list_managed_instances_results = "PAGELESS"

### Unmanaged Instance Group Configuration ###
# instances = [ "" ] 
# network = "gyeongsik-dev"