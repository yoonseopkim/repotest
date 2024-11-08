resource "aws_lb_listener" "mongo" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 27017                             // 클라이언트가 LB에 접근하는 포트(클라이언트->LB)
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.gitfolio_issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mongo.arn
  }
  
  tags = {
    Name = "Gitfolio MongoDB listner"
  }
}

resource "aws_lb_target_group" "mongo" {
  name                  = "gitfolio-mongo-tg"
  port                  = var.target_port["mongo"]      // LB가 타겟으로 트래픽을 전달하는 포트(ALB->target(instance))
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
    Name = "Gitfolio lb MongoDB target group"
  }
}

resource "aws_lb_target_group_attachment" "mongo" {
  target_group_arn = aws_lb_target_group.mongo.arn
  target_id        = var.mongo_id
}

// =====================================================================

resource "aws_lb_listener" "redis" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 6379                             // 클라이언트가 LB에 접근하는 포트(클라이언트->LB)
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.gitfolio_issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redis.arn
  }
  
  tags = {
    Name = "Gitfolio Redis listner"
  }
}

resource "aws_lb_target_group" "redis" {
  name                  = "gitfolio-redis-tg"
  port                  = var.target_port["redis"]      // LB가 타겟으로 트래픽을 전달하는 포트(ALB->target(instance))
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
    Name = "Gitfolio lb Redis target group"
  }
}

resource "aws_lb_target_group_attachment" "redis" {
  target_group_arn = aws_lb_target_group.redis.arn
  target_id        = var.redis_id
}
