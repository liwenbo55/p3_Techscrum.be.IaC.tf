# data "aws_ssm_parameters_by_path" "config_params" {
#   path = "/techscrum/"
# }

##########################################################################
# Data from SSM parameter store
##########################################################################
data "aws_ssm_parameter" "environment" {
  name = "/techscrum/ENVIRONMENT"
}

data "aws_ssm_parameter" "name" {
  name = "/techscrum/NAME"
}

data "aws_ssm_parameter" "port" {
  name = "/techscrum/PORT"
}

data "aws_ssm_parameter" "api_prefix" {
  name = "/techscrum/API_PREFIX"
}

data "aws_ssm_parameter" "region" {
  name = "/techscrum/REGION"
}

data "aws_ssm_parameter" "access_key_id" {
  name = "/techscrum/ACCESS_KEY_ID"
}

data "aws_ssm_parameter" "secret_access_key" {
  name = "/techscrum/SECRET_ACCESS_KEY"
}

data "aws_ssm_parameter" "access_secret" {
  name = "/techscrum/ACCESS_SECRET"
}

data "aws_ssm_parameter" "email_secret" {
  name = "/techscrum/EMAIL_SECRET"
}

data "aws_ssm_parameter" "forget_secret" {
  name = "/techscrum/FORGET_SECRET"
}

data "aws_ssm_parameter" "limiter" {
  name = "/techscrum/LIMITER"
}

data "aws_ssm_parameter" "public_connection" {
  name = "/techscrum/PUBLIC_CONNECTION"
}

data "aws_ssm_parameter" "tenants_connection" {
  name = "/techscrum/TENANTS_CONNECTION"
}

data "aws_ssm_parameter" "main_domain" {
  name = "/techscrum/MAIN_DOMAIN"
}

data "aws_ssm_parameter" "stripe_private_key" {
  name = "/techscrum/STRIPE_PRIVATE_KEY"
}

data "aws_ssm_parameter" "stripe_webhook_secret" {
  name = "/techscrum/STRIPE_WEBHOOK_SECRET"
}
