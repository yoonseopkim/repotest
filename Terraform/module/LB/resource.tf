resource "aws_security_group" "alb" {
  name = "alb_sg"
  vpc_id = var.vpc_id

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.any_ip]
  }

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

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.any_ip]
  }

  tags = {
    Name = "Gitfolio ArgoCD security group"
  }
}

resource "aws_lb" "alb" {
  name                       = "gitfolio-alb"
  internal                   = false
  load_balancer_type         = var.lb_type
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [var.public_subnet_ids[0], var.public_subnet_ids[1]]

  enable_deletion_protection = var.delete_protection

  tags = {
    Name = "Gitfolio load balancer"
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
    Name = "Gitfolio HTTP listner"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443                             // 클라이언트가 LB에 접근하는 포트(클라이언트->LB)
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.gitfolio_issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }

  tags = {
    Name = "Gitfolio HTTPS listner"
  }
}

resource "aws_lb_target_group" "alb" {
  name                  = "gitfolio-tg"
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
    Name = "Gitfolio lb target group"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = var.frontend_id
}