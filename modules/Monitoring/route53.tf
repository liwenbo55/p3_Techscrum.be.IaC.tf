#######################################################################################################################################
# Health check in route53 (for Backend url) & Cloudwatch Alarm for health check
#######################################################################################################################################
resource "aws_route53_health_check" "backend_healthcheck" {
  fqdn              = var.backend_fqdn
  port              = 443
  type              = "HTTPS"
  resource_path     = "/api/v2/healthcheck"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "tf-test-health-check"
    Name = "${var.project_name}-backend-health-check-${var.environment}"
  }
}

# The alarm for route53 must be located in the us-east-1 region.
provider "aws" {
    alias  = "Virginia"
    region = "us-east-1"
}

resource "aws_cloudwatch_metric_alarm" "healthcheck_alarm" {
  provider            = aws.Virginia
  alarm_name          = "${var.project_name}-backend-health-check-alarm-${var.environment}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  alarm_description = <<-EOT
    This alarm uses Route53 healthcheckers to detect unhealthy endpoints.
    The status of the endpoint is reported as 1 when it's healthy. 
    Everything less than 1 is unhealthy.
  EOT

  dimensions = {
    HealthCheckId = aws_route53_health_check.backend_healthcheck.id
  }
}
