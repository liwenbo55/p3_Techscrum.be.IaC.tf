#######################################################################################################################
# ECS task_execution_role 
# （Task execution role that the Amazon ECS container agent and the Docker daemon can assume.）
# （Role for ECS service itself, it is mainly used for operations required for task execution, 
#   such as pulling container images and storing logs.）
#######################################################################################################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name        = "${var.project_name}-ecs-task-execution-role-${var.environment}"
  description = "IAM Role for ECS task execution for ${var.environment} environment."
  assume_role_policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach "SSMReadOnlyAcces" policy to ecs_task_execution_role. 
# (In order to read parameters(SecureString type) from SSM parameter store)
resource "aws_iam_role_policy_attachment" "AmazonSSMReadOnlyAccess" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

##############################################################################################################
#  ECS task_role in ecs
# (IAM role that allows your Amazon ECS container task to make calls to other AWS services.)
##############################################################################################################
# This role is same with ecs_task_execution_role in this project.()