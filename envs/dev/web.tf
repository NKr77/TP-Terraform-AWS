data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "alb" {
  name        = "novasphere-${var.environment}-alb"
  description = "Autorise HTTP depuis Internet vers ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web" {
  name        = "novasphere-${var.environment}-web"
  description = "Autorise HTTP uniquement depuis ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP depuis ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "novasphere-${var.environment}-"
  image_id      = data.aws_ami.debian.id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = base64encode(
    file("${path.module}/bootstrap.sh")
  )

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "novasphere-${var.environment}-web"
    }
  }
}

resource "aws_lb" "web" {
  name               = "novasphere-${var.environment}"
  load_balancer_type = "application"

  subnets = module.vpc.public_subnets

  security_groups = [
    aws_security_group.alb.id
  ]
}

resource "aws_lb_target_group" "web" {
  name     = "novasphere-${var.environment}-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path    = "/"
    matcher = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_autoscaling_group" "web" {
  name = "novasphere-${var.environment}-web"

  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = module.vpc.public_subnets

  target_group_arns = [
    aws_lb_target_group.web.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "novasphere-${var.environment}-web"
    propagate_at_launch = true
  }
}
