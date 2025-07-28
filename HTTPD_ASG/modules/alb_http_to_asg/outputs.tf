output "alb_dns_name" {
  value = aws_lb.http_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.asg_tg.arn
}

output "alb_listener_arn" {
  value = aws_lb_listener.http_listener.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

# output "alb_sg_id" {
#   value = aws_security_group.alb_sg.id
# }

