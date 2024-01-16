##########################################################################
# load balancer target group
##########################################################################
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.project_name}-alb-target-group-${var.environment}"
  target_type = "ip"
  protocol    = "HTTP"
  port        = 8000
  vpc_id      = var.alb_target_group_vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/api/v2/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200-399"
  }
  tags = {
    Environment = var.environment
  }
}

##########################################################################
# load balancer
##########################################################################
resource "aws_lb" "backend_alb" {
  load_balancer_type = "application"
  name               = "${var.project_name}-backend-alb-${var.environment}"
  security_groups    = var.alb_security_groups
  subnets            = var.alb_vpc_subnets
  #   enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_lb_listener" "backend_alb_80" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "backendalb_443" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.acm_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

##########################################################################
# Create A record for load balancer
##########################################################################
resource "aws_route53_record" "a_record_for_alb" {
  zone_id = var.hosted_zone_id
  name    = "backend.${var.environment}.${var.hosted_zone_name}"
  type    = var.record_type_A

  alias {
    name                   = aws_lb.backend_alb.dns_name
    zone_id                = aws_lb.backend_alb.zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

##########################################################################
# Add SSL certificate for load balancer A record
##########################################################################
resource "aws_acm_certificate" "acm_certificate" {
  domain_name = "backend.${var.environment}.${var.hosted_zone_name}"
  # subject_alternative_names = ["backend.${var.environment}.${var.project_name}.com"]
  validation_method = var.validation_method
  key_algorithm     = var.key_algorithm

  tags = {
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ACM validation (add CNAME records to route53)
resource "aws_route53_record" "validation" {
  depends_on = [aws_acm_certificate.acm_certificate]

  zone_id = var.hosted_zone_id

  ttl = var.ACM_validation_ttl

  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
}

resource "aws_acm_certificate_validation" "acm_certificate" {
  depends_on              = [aws_route53_record.validation]
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
