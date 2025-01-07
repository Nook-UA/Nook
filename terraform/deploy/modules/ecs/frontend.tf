resource "aws_ecs_service" "nook_web_service" {
    name = "nook-web-service"
    cluster = aws_ecs_cluster.nook_ecs.id
    task_definition = aws_ecs_task_definition.web_task_definition.arn
    desired_count = 1

    force_new_deployment = true

    network_configuration {
        subnets = var.private_subnet_ids
        security_groups = [aws_security_group.web_intance_sg.id]
        assign_public_ip = false
    }

    capacity_provider_strategy {
        capacity_provider = aws_ecs_capacity_provider.nook_ecs_capacity_provider.name
        base = 1
        weight            = 100
    }

    ordered_placement_strategy {
        type  = "spread"
        field = "attribute:ecs.availability-zone"
    }

    lifecycle {
      ignore_changes = [desired_count]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.web_tg.arn
        container_name   = "nook-web-container"
        container_port   = 3000
    }
}

resource "aws_ecs_task_definition" "web_task_definition" {
    family = "nook-web-task-definition"
    network_mode = "awsvpc"
    cpu = 256
    memory = 512
    task_role_arn      = aws_iam_role.ecs_task_role.arn
    execution_role_arn = aws_iam_role.ecs_exec_role.arn

    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture = "X86_64"
    }

    container_definitions = jsonencode([{
        name = "nook-web-container",
        image = "418272757612.dkr.ecr.eu-west-3.amazonaws.com/nook/web:latest",
        portMappings = [
            {
                containerPort = 3000
                hostPort = 3000
            }
        ],

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                awslogs-group = aws_cloudwatch_log_group.nook_web_log_group.name
                awslogs-region = "eu-west-3"
                awslogs-stream-prefix = "nook-web"
            }
        },

        environment = [
            {
                name = "NEXTAUTH_SECRET"
                value = var.next_auth_secret
            },
            {
                name = "BACKEND_URL"
                value = "http://${aws_lb.lb.dns_name}/api"
            },
            {
                name = "PARKING_DETECTION_URL"
                value = "http://${aws_lb.lb.dns_name}/parking_detection"
            },
            {
                name = "COGNITO_CLIENT_ID"
                value = var.cognito_app_client_id
            },
            {
                name = "COGNITO_CLIENT_SECRET"
                value = var.cognito_client_secret
            },
            {
                name = "COGNITO_DOMAIN"
                value = "https://cognito-idp.${var.aws_default_region}.amazonaws.com/${var.cognito_user_pool_id}"
            },  
            {
                name = "COGNITO_POOL_ID"
                value = var.cognito_user_pool_id
            },
            {
                name = "NEXT_PUBLIC_LOGOUT_URL"
                value = "https://${var.cognito_domain_host}.auth.${var.aws_default_region}.amazoncognito.com/logout?client_id=${var.cognito_app_client_id}&logout_uri=http%3A%2F%2F${aws_lb.lb.dns_name}%2F"
            },
            {
                name = "NEXT_PUBLIC_GOOGLE_MAPS_API_KEY"
                value = var.next_public_google_maps_api_key
            },
        ]
    }])
  
}

resource "aws_security_group" "web_intance_sg" {
    name = "web_intance_sg"
    description = "web_intance_sg"
    vpc_id = var.vpc_id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_cloudwatch_log_group" "nook_web_log_group" {
  name              = "/ecs/nook-web-logs"
  retention_in_days = 7
}