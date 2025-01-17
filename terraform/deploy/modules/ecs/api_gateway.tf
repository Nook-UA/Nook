# ===== BACKED LOAD BALANCER =====

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ecs_lb" {
  name               = "ecs-load-balancer"
  internal           = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb_sg.id]
  subnets            = var.private_subnet_ids
}

resource "aws_lb_listener" "ecs_lb_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found. Try /api or /parking-detection"
      status_code = "404"
    }
  }
}

resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.ecs_lb_listener.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api*"]
    }
  }
}

resource "aws_lb_listener_rule" "parking_detection_rule" {
  listener_arn = aws_lb_listener.ecs_lb_listener.arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.parking_detection_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/parking-detection*"]
    }
  }
}

resource "aws_lb_target_group" "backend_target_group" {
  name        = "backend-target-group"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/api"
  }
}

resource "aws_lb_target_group" "parking_detection_target_group" {
  name        = "parking-detection-target-group"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/parking-detection/health"
  }
}


# ===== API_GATEWAY =====

resource "aws_security_group" "vpc_link" {
  name        = "vpc-link-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "api-gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "sample_stage_resource" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  name   = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "vpc_link"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = [element(var.private_subnet_ids,0)]
}

resource "aws_apigatewayv2_integration" "api_gateway_integration" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type = "VPC_LINK"
  integration_uri = aws_lb_listener.ecs_lb_listener.arn
  connection_id = aws_apigatewayv2_vpc_link.vpc_link.id
}

resource "aws_apigatewayv2_route" "alb_connection" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.api_gateway_integration.id}"
  authorization_type = "NONE"
}