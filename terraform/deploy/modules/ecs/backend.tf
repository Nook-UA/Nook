resource "aws_ecs_service" "nook_rest_api_service" {
    name = "nook-rest-api-service"
    cluster = aws_ecs_cluster.nook_ecs.id
    task_definition = aws_ecs_task_definition.rest_api_task_definition.arn
    desired_count = 1

    force_new_deployment = true

    network_configuration {
        subnets = var.private_subnet_ids
        security_groups = [aws_security_group.backend_ec2.id]
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
        target_group_arn = aws_lb_target_group.backend_target_group.arn
        container_name   = "nook-rest-api-container"
        container_port   = 8000
    }
}

resource "aws_ecs_task_definition" "rest_api_task_definition" {
    family = "nook-rest-api-task-definition"
    network_mode = "awsvpc"
    cpu = 256
    memory = 512
    
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture = "X86_64"
    }

    container_definitions = jsonencode([{
        name = "nook-rest-api-container",
        image = "418272757612.dkr.ecr.eu-west-3.amazonaws.com/nook/rest_api:latest",
        portMappings = [
            {
                containerPort = 8000
                hostPort = 8000
            }
        ],

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                awslogs-group = aws_cloudwatch_log_group.nook_rest_api_log_group.name
                awslogs-region = "eu-west-3"
                awslogs-stream-prefix = "nook-rest-api"
            }
        },

        environment = [
            {
                name = "S3_URL"
                value = var.s3_url
            },
            {
                name = "DB_HOST"
                value = var.db_address
            },
            {
                name = "DB_PORT"
                value = "5432"
            },
            {
                name = "DB_USER"
                value = var.db_user
            },
            {
                name = "DB_PASSWORD"
                value = var.db_password
            },
            {
                name = "DB_NAME"
                value = var.db_name
            },
            {
                name = "AWS_DEFAULT_REGION"
                value = var.aws_default_region
            },
            {
                name = "COGNITO_USER_POOL_ID"
                value = var.cognito_user_pool_id
            },
            {
                name = "COGNITO_APP_CLIENT_ID"
                value = var.cognito_app_client_id
            },
            {
                name = "PARKSERVICE_URL"
                value = "${aws_apigatewayv2_api.api_gateway.api_endpoint}/parking-detection"
            }
        ]
    }])
  
}

resource "aws_security_group" "backend_ec2" {
    name = "backend_ec2"
    vpc_id = var.vpc_id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_cloudwatch_log_group" "nook_rest_api_log_group" {
  name              = "/ecs/nook-rest-api-service"
  retention_in_days = 7
}