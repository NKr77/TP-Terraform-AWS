data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
resource "aws_launch_template" "web" {
  name_prefix   = "novasphere-${var.environment}-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.web.id
    ]
  }


  user_data = base64encode(
    file("${path.module}/bootstrap.sh")
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "novasphere-${var.environment}-web"
    }
  }

  tags = {
    Name = "novasphere-${var.environment}-template"
  }
}
