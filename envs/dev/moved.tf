moved {
  from = aws_security_group.alb
  to   = module.web.aws_security_group.alb
}

moved {
  from = aws_security_group.web
  to   = module.web.aws_security_group.web
}

moved {
  from = aws_launch_template.web
  to   = module.web.aws_launch_template.web
}

moved {
  from = aws_lb.web
  to   = module.web.aws_lb.web
}

moved {
  from = aws_lb_target_group.web
  to   = module.web.aws_lb_target_group.web
}

moved {
  from = aws_lb_listener.http
  to   = module.web.aws_lb_listener.http
}

moved {
  from = aws_autoscaling_group.web
  to   = module.web.aws_autoscaling_group.web
}
