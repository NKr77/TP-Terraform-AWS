resource "aws_security_group" "alb" {
  name        = "novasphere-${var.environment}-alb-sg"
  description = "Pare-feu du Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "novasphere-${var.environment}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "10.0.0.0/16"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}
resource "aws_security_group" "web" {
  name        = "novasphere-${var.environment}-web-sg"
  description = "Pare-feu des serveurs web"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "novasphere-${var.environment}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id            = aws_security_group.web.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}
