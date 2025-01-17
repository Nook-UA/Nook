resource "aws_ecs_service" "nook_parking_detection_service" {
    name = "nook-parking-detection-service"
    cluster = aws_ecs_cluster.nook_ecs.id
    task_definition = aws_ecs_task_definition.parking_detection_task_definition.arn
    desired_count = 1

    force_new_deployment = true

    network_configuration {
        subnets = var.private_subnet_ids
        security_groups = [aws_security_group.parking_detection_ec2.id]
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
        target_group_arn = aws_lb_target_group.parking_detection_target_group.arn
        container_name   = "nook-parking-detection-container"
        container_port   = 8000
    }
}

resource "aws_ecs_task_definition" "parking_detection_task_definition" {
    family = "nook-parking-detection-task-definition"
    network_mode = "awsvpc"
    cpu = 256
    memory = 512
    
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture = "X86_64"
    }

    container_definitions = jsonencode([{
        name = "nook-parking-detection-container",
        image = "418272757612.dkr.ecr.eu-west-3.amazonaws.com/nook/parking-detection:latest",
        portMappings = [
            {
                containerPort = 8000
                hostPort = 8000
            }
        ],

        logConfiguration = {
            logDriver = "awslogs"
            options = {
                awslogs-group = aws_cloudwatch_log_group.nook_parking_detection_log_group.name
                awslogs-region = "eu-west-3"
                awslogs-stream-prefix = "nook-parking-detection"
            }
        },

        environment = [
            {
                name = "REDIS_HOST"
                value = var.redis_host
            },
            {
                name = "REDIS_PORT"
                value = var.redis_port
            }
        ]
    }])
  
}

resource "aws_security_group" "parking_detection_ec2" {
    name = "parking_detection_ec2"
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

    ingress {
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_cloudwatch_log_group" "nook_parking_detection_log_group" {
  name              = "/ecs/nook-parking-detection-service"
  retention_in_days = 7
}