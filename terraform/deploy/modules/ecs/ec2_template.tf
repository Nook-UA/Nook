data "aws_ssm_parameter" "ecs_node_ami" {
    name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_launch_template" {
    name_prefix = "ecs-launch-template-"
    image_id = data.aws_ssm_parameter.ecs_node_ami.value
    instance_type = "t2.micro"

    iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
    monitoring { enabled = true }

    block_device_mappings {
        device_name = "/dev/xvda"
        ebs {
            volume_size = 30
        }
    }

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "ecs-instance"
        }
    }

    user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=nook-cluster-ecs >> /etc/ecs/ecs.config;
    EOF
    )

    
}

# --- ECS Node Role ---

data "aws_iam_policy_document" "ecs_node_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_node_role" {
  name_prefix        = "demo-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_doc.json
}

resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role       = aws_iam_role.ecs_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_node" {
  name_prefix = "demo-ecs-node-profile"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs_node_role.name
}