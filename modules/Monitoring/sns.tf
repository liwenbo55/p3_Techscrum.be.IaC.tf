##################################################
# Create sns topic & subscription
##################################################
resource "aws_sns_topic" "backend_sns" {
  name = "${var.project_name}-backend-sns-${var.environment}"
}
resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.backend_sns.arn
  protocol  = "email"
  endpoint  = var.sns_email
}