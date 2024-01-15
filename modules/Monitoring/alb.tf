#####################################################################################
# Cloudwatch dashboard -- ALB dashboard (Metrics: RequestCount & TargetResponseTime)
#####################################################################################
resource "aws_cloudwatch_dashboard" "alb_dashboard" {
  dashboard_name = "${var.project_name}-ALB-Dashboard-${var.environment}"

  dashboard_body = jsonencode({
    "widgets" : [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer", "${var.alb_arn_suffix}",
              { "label" : "ALB Request Count" }
            ]
          ],
          "view" : "timeSeries",
          "period" : 60,
          "stat" : "Sum",
          "region" : "ap-southeast-2",
          "title" : "ALB Request Count"
        }
      },
      {
        "type" : "metric",
        "width" : 24,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer", "${var.alb_arn_suffix}",
              "TargetGroup", "${var.alb_target_group_arn_suffix}",
              "AvailabilityZone", "ap-southeast-2a",
              { "label" : "ap-southeast-2a Response Time" }
            ],
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer", "${var.alb_arn_suffix}",
              "TargetGroup", "${var.alb_target_group_arn_suffix}",
              "AvailabilityZone", "ap-southeast-2b",
              { "label" : "ap-southeast-2b Response Time" }
            ]
          ],
          "view" : "timeSeries",
          "period" : 300,
          "stat" : "Average",
          "region" : "ap-southeast-2",
          "title" : "ALB Target Response Time"
        }
      }
    ]
  })
}


# Alarm for alb response time

# Create alarm (Action is to send notification to email.)
resource "aws_cloudwatch_metric_alarm" "alb_response_time_alarm" {
  alarm_name          = "${var.project_name}-backend-alb-response-time-alarm-${var.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.5"
  alarm_description   = "This alarm is for backend ALB respronse time."
  alarm_actions       = [aws_sns_topic.backend_sns.arn]
  dimensions = {
    LoadBalancer = "${var.alb_arn_suffix}"
  }
}