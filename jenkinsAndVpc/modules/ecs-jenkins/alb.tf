resource "aws_alb" "alb_jenkins_controller" {
  name                       = "alb-jenkins-controller"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_security_group.id]
  subnets                    = var.public_subnets
  ip_address_type            = "ipv4"
  enable_deletion_protection = false
}

resource "aws_alb_target_group" "jenkins_controller_tg" {
  name        = "alb-http-jenkins-controller"
  port        = var.controller_listening_port
  target_type = "ip"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  health_check {
    path                = "/login"
    timeout             = 10
    interval            = 100
    healthy_threshold   = 3
    unhealthy_threshold = 10
  }

  lifecycle {
    create_before_destroy = true
  }
}

# This listener is used when dont't use https with the ALB
resource "aws_lb_listener" "controller_http" {
  load_balancer_arn = aws_alb.alb_jenkins_controller.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.jenkins_controller_tg.arn
  }
  depends_on = [aws_alb_target_group.jenkins_controller_tg]
}
