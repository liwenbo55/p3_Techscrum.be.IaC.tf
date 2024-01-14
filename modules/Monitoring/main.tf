##############################################################################################
# Health check in route53 for Backend url & cloudwatch Alarm for health check
##############################################################################################
resource "aws_route53_health_check" "example" {
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

# resource "aws_cloudwatch_metric_alarm" "foobar" {
#   alarm_name          = "${var.project_name}-backend-health-check-alarm-${var.environment}"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/Route53"
#   period              = "120"
#   statistic           = "Average"
#   threshold           = "80"
#   alarm_description   = "This metric monitors ec2 cpu utilization"
# }