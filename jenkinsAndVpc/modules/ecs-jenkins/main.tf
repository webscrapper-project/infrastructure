terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 2.23.1"
    }
  }
}

locals {
  jenkins_controller_container_name = "jenkins-controller"
  jenkins_home                      = "/var/jenkins_home"
  # Jenkins home inside the container. This is hard coded in the official docker image
  efs_volume_name    = "jenkins-efs-configuration"
  jenkins_public_url = "http://${aws_alb.alb_jenkins_controller.dns_name}"
}


# The cluster for Jenkins: controller and agents
resource "aws_ecs_cluster" "cluster" {
  name = "jenkins-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = var.project_name
    Name = "Jenkins"
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_efs_file_system" "jenkins_conf" {
  performance_mode                = var.efs_performance_mode
  throughput_mode                 = var.efs_throughput_mode
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput_in_mibps
  tags = {
    Project = var.project_name
    Name = "jenkins-controller-configuration"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "mount_targets" {
  count           = var.private_subnet_count
  file_system_id  = aws_efs_file_system.jenkins_conf.id
  subnet_id       = element([for subnet in var.private_subnets : subnet], count.index)
  security_groups = [aws_security_group.efs.id]
}

resource "aws_ecs_task_definition" "jenkins_controller" {
  family                   = "jenkins-controller"
  execution_role_arn       = aws_iam_role.controller_ecs_execution_role.arn
  task_role_arn            = aws_iam_role.controller_ecs_task_role.arn
  cpu                      = var.controller_cpu_memory.cpu
  memory                   = var.controller_cpu_memory.memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  volume {
    name = local.efs_volume_name

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.jenkins_conf.id
      root_directory = "/"
    }
  }

  container_definitions = templatefile("${path.module}/templates/ecs-task.template.json", {
    image             = local.controller_docker_image
    region            = var.aws_region
    log_group_name    = aws_cloudwatch_log_group.jenkins_controller.id
    jenkins_http_port = var.controller_listening_port
    jenkins_jnlp_port = var.controller_jnlp_port
    env_vars = jsonencode([
      { name : "JENKINS_JAVA_OPTS", value : var.controller_java_opts },
      {
        name : "JENKINS_CONF_S3_URL",
        value : "s3://${aws_s3_object.jenkins_conf.bucket}/${aws_s3_object.jenkins_conf.key}"
      },
      # This will force the creation of a new version of the task definition if the configuration changes and cause ECS to launch
      # a new container.
      { name : "JENKINS_CONF_S3_VERSION_ID", value : aws_s3_object.jenkins_conf.version_id }
    ])
    jenkins_controller_container_name = local.jenkins_controller_container_name
    efs_volume_name                   = local.efs_volume_name
    jenkins_user_uid                  = var.controller_docker_user_uid_gid
    jenkins_home                      = local.jenkins_home
  })
  tags = {
    Project = var.project_name
    Name = "Jenkins Task"
  }
}

resource "aws_ecs_service" "jenkins_controller" {
  name            = "jenkins-controller"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.jenkins_controller.arn
  desired_count   = 1
  # only one controller should be up and running. Open Source version of Jenkins is not adapted for multi controllers mode
  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version

  deployment_minimum_healthy_percent = var.controller_deployment_percentages.min
  deployment_maximum_percent         = var.controller_deployment_percentages.max

  network_configuration {
    security_groups  = [aws_security_group.jenkins_controller_ecs_service.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  # alb http target group
  load_balancer {
    target_group_arn = aws_alb_target_group.jenkins_controller_tg.arn
    container_name   = local.jenkins_controller_container_name
    container_port   = var.controller_listening_port
  }

  # nlb http for agents
  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_agents_to_controller_http.arn
    container_name   = local.jenkins_controller_container_name
    container_port   = var.controller_listening_port
  }

  # nlb jnlp for agents
  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_agents_to_controller_jnlp.arn
    container_name   = local.jenkins_controller_container_name
    container_port   = var.controller_jnlp_port
  }

  tags = {
    Project = var.project_name
    Name = "Jenkins Service"
  }

  # the listeners that attach the target groups to the load balancers need to be created first. Otherwise, there will
  # be an error saying that the target group is not attached to a load balancer.
  depends_on = [
    aws_lb_listener.controller_http,
    aws_lb_listener.agents_http_listener,
    aws_lb_listener.agents_jnlp_listener,
  ]
}