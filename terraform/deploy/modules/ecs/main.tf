resource "aws_ecs_cluster" "nook_ecs" {
    name = "nook-cluster-ecs"
}

resource "aws_ecs_capacity_provider" "nook_ecs_capacity_provider" {
    name = "nook-ecs-capacity-provider"
    auto_scaling_group_provider {
        auto_scaling_group_arn = aws_autoscaling_group.asg.arn

        managed_scaling {
            maximum_scaling_step_size = 2
            minimum_scaling_step_size = 1
            status = "ENABLED"
            target_capacity = 100
        }
    }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  min_size         = 1
  desired_capacity = 3
  max_size         = 3

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Nook-ecs-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster_capacity_providers" "nook_ecs_cluster_capacity_provider" {
    cluster_name = aws_ecs_cluster.nook_ecs.name
    capacity_providers = [aws_ecs_capacity_provider.nook_ecs_capacity_provider.name]

    default_capacity_provider_strategy {
      capacity_provider = aws_ecs_capacity_provider.nook_ecs_capacity_provider.name
      base              = 1
      weight            = 100
    }
}