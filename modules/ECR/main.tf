resource "aws_ecr_repository" "backend_ECR" {
  name                 = "${var.project_name}-backend-ecr-${var.environment}"
  image_tag_mutability = var.image_tag_mutability

  force_delete = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}