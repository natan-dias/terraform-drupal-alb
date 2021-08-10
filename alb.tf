resource "aws_lb" "lb" {
  name            = "AwsLoadBalancer"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.public_1.id}", "${aws_subnet.public_2.id}"]

  tags = {
    Name = "ALB"
  }
}

resource "aws_lb_target_group" "lb_tg" { #Only for test environment. For production use preferably 443 HTTPS.
  name     = "ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev.id

  health_check {
    path              = "/"
    healthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "lb_tg_att1" { #Only for test environment. For production use preferably 443 HTTPS.
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.drupal1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "lb_tg_att2" { #Only for test environment. For production use preferably 443 HTTPS.
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.drupal2.id
  port             = 80
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}