resource "aws_security_group" "alb" {
  name = "alb_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  ingress {
    description = "Gitfolio API"
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.any_ip]
  }

  tags = {
    Name = "Gitfolio load balancer security group"
  }
}

resource "aws_lb" "alb" {
  name                       = "gitfolio-alb"
  internal                   = false
  load_balancer_type         = var.lb_type
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids

  enable_deletion_protection = var.delete_protection

  tags = {
    Name = "Gitfolio ${terraform.workspace} load balancer"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80                              // 클라이언트가 LB에 접근하는 포트(클라이언트->LB)
  protocol          = "HTTP"

  default_action {
    type            = "redirect"

    redirect {
      port          = 443
      protocol      = "HTTPS"
      status_code   = "HTTP_301"
    }
  }

  tags = {
    Name = "Gitfolio ${terraform.workspace} HTTP listner"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443                             // 클라이언트가 LB에 접근하는 포트(클라이언트->LB)
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.gitfolio_issued.arn

  default_action {
    type           = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Invalid host"
      status_code  = "404"
    }
  }
  
  tags = {
    Name = "Gitfolio default listner"
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 5000                             // 클라이언트가 LB에 접근하는 포트(클라이언트->LB)
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.gitfolio_issued.arn

  default_action {
    type           = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Invalid host"
      status_code  = "404"
    }
  }
  
  tags = {
    Name = "Gitfolio api listner"
  }
}

resource "aws_lb_listener_rule" "https" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 50000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }

  condition {
    host_header {
      values = ["www.gitfolio.site"]
    }
  }

  tags = {
    Name = "Gitfolio ${terraform.workspace} HTTPS listner"
  }
}

resource "aws_lb_listener_rule" "auth_routing" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_auth.arn
  }

  condition {
    path_pattern {
      values = ["/oauth2/*", "/login/*"]
    }
  }

  tags = {
    Name = "Gitfolio auth path based routing"
  }
}

resource "aws_lb_listener_rule" "ai_routing" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ai.arn
  }

  condition {
    host_header {
      values = ["api.gitfolio.site"]
    }
  }

  condition {
    path_pattern {
      values = ["/docs/*"]
    }
  }

  tags = {
    Name = "Gitfolio ai host header based routing"
  }
}

resource "aws_lb_target_group" "alb" {
  name                  = "gitfolio-front-tg"
  port                  = var.target_port      // LB가 타겟으로 트래픽을 전달하는 포트(ALB->target(instance))
  protocol              = var.target_protocol
  vpc_id                = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = var.health_threshold
    interval            = var.health_interval
    matcher             = var.health_matcher
    path                = var.health_path
    port                = var.health_port
    protocol            = var.health_protocol
    timeout             = var.health_timeout
    unhealthy_threshold = var.health_unthreshold
  }

  tags = {
    Name = "Gitfolio lb frontend target group"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = var.frontend_id
}

resource "aws_lb_target_group" "alb_auth" {
  name                  = "gitfolio-auth-tg"
  port                  = var.target_port      // LB가 타겟으로 트래픽을 전달하는 포트(ALB->target(instance))
  protocol              = var.target_protocol
  vpc_id                = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = var.health_threshold
    interval            = var.health_interval
    matcher             = var.health_matcher
    path                = var.health_path
    port                = var.health_port
    protocol            = var.health_protocol
    timeout             = var.health_timeout
    unhealthy_threshold = var.health_unthreshold
  }

  tags = {
    Name = "Gitfolio lb auth module target group"
  }
}

resource "aws_lb_target_group_attachment" "backend_auth" {
  target_group_arn = aws_lb_target_group.alb_auth.arn
  target_id        = var.backend_auth_id
}

resource "aws_lb_target_group" "alb_ai" {
  name                  = "gitfolio-ai-tg"
  port                  = var.target_port      // LB가 타겟으로 트래픽을 전달하는 포트(ALB->target(instance))
  protocol              = var.target_protocol
  vpc_id                = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = var.health_threshold
    interval            = var.health_interval
    matcher             = var.health_matcher
    path                = var.health_path
    port                = var.health_port
    protocol            = var.health_protocol
    timeout             = var.health_timeout
    unhealthy_threshold = var.health_unthreshold
  }

  tags = {
    Name = "Gitfolio lb ai target group"
  }
}

resource "aws_lb_target_group_attachment" "ai" {
  target_group_arn = aws_lb_target_group.alb_ai.arn
  target_id        = var.ai_id
}