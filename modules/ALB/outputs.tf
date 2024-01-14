output "alb_target_group_arn" {
  value = aws_lb_target_group.alb_target_group.arn
}

output "backend_fqdn" {
  value = aws_route53_record.a_record_for_alb.fqdn
}

output "alb_arn_suffix" {
  value = aws_lb.backend_alb.arn_suffix
}
