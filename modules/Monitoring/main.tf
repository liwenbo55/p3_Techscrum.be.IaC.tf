##############################################################################################
# Health check in route53 for Backend url & cloudwatch Alarm for health check
##############################################################################################
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

# ##############################################################################################
# # alb_response_time_alarm
# ##############################################################################################
# resource "aws_cloudwatch_metric_alarm" "alb_response_time_alarm" {
#   alarm_name          = "alb_response_time_alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   metric_name         = "TargetResponseTime"
#   namespace           = "AWS/ApplicationELB"
#   period              = "60"
#   statistic           = "Average"
#   threshold           = "0.5"
#   alarm_description   = "This metric checks response time"
# #   alarm_actions       = [aws_sns_topic.backend_sns.arn]
# #   dimensions = {
# #     LoadBalancer = "${var.alb_arn_suffix}"
# #   }
# }

##############################################################################################
# Cloudwatch dashboard
##############################################################################################
resource "aws_cloudwatch_dashboard" "alb_dashboard" {
  dashboard_name = "${var.project_name}-ALB-Dashboard-${var.environment}"

  dashboard_body = jsonencode({
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 6,
            "properties": {        
                "metrics": [
                    [
                        "AWS/ApplicationELB", 
                        "RequestCount", 
                        "LoadBalancer", "${var.alb_arn_suffix}", 
                        { "label": "ALB Request Count" } 
                    ]
                ],
            "view": "timeSeries",
            "period": 60,
            "stat": "Sum",
            "region":"ap-southeast-2",
            "title": "ALB Request Count"
            }
        },
        {
            "type": "metric",
            "width": 24,
            "height": 6,
            "properties": {        
                "metrics": [
                    [
                        "AWS/ApplicationELB", 
                        "TargetResponseTime", 
                        "LoadBalancer", "${var.alb_arn_suffix}", 
                        # "TargetGroup","targetgroup/techscrum-alb-target-group-ll/76d0c95d5c3cb5e5",
                        "TargetGroup","${var.alb_target_group_arn_suffix}",
                        "AvailabilityZone","ap-southeast-2a",
                        { "label": "ap-southeast-2a Response Time" } 
                    ],
                    [
                        "AWS/ApplicationELB", 
                        "TargetResponseTime", 
                        "LoadBalancer", "${var.alb_arn_suffix}", 
                        # "TargetGroup","targetgroup/techscrum-alb-target-group-ll/76d0c95d5c3cb5e5",
                        "TargetGroup","${var.alb_target_group_arn_suffix}",
                        "AvailabilityZone","ap-southeast-2b",
                        { "label": "ap-southeast-2b Response Time" } 
                    ]
                ],
            "view": "timeSeries",
            "period": 300,
            "stat": "Average",
            "region":"ap-southeast-2",
            "title": "ALB Target Response Time"
            }
        }
    ]
  })
}