resource "aws_security_group" "lb" {
  name        = "Nook-lb-sg"
  description = "Allow HTTP access to UI & API instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "lb" {
  name               = "Nook-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found."
      status_code  = "404"
    }
  }
}

# ===== Rest API =====
resource "aws_lb_listener_rule" "rest_api_rule" {
  listener_arn = aws_lb_listener.listener_http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rest_api_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/park/*", "/api/client/*"]
    }
  }
}

resource "aws_lb_target_group" "rest_api_tg" {
  name        = "rest-api-target-group"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }
}

# ===== Web =====
resource "aws_lb_listener_rule" "web_rule" {
  listener_arn = aws_lb_listener.listener_http.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group" "web_tg" {
  name        = "web-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }
}