resource "aws_security_group" "web_sg" {
  description = var.websg.description
  egress {
    from_port   = var.websg.egress_rules.from
    to_port     = var.websg.egress_rules.to
    protocol    = var.websg.egress_rules.protocol
    cidr_blocks = [var.websg.egress_rules.cidr]
    description = var.websg.egress_rules.description
  }
  ingress {
    from_port   = var.websg.ingress_rules.from
    to_port     = var.websg.ingress_rules.to
    protocol    = var.websg.ingress_rules.protocol
    cidr_blocks = [var.websg.ingress_rules.cidr]
    description = var.websg.ingress_rules.description
  }
  name   = var.websg.name
  vpc_id = aws_vpc.ntier.id
}

resource "aws_security_group" "db_sg" {
  description = var.db_sg.description
  name        = var.db_sg.name
  vpc_id      = aws_vpc.ntier.id
  egress {
    from_port   = var.db_sg.egress_rules.from
    to_port     = var.db_sg.egress_rules.to
    protocol    = var.db_sg.egress_rules.protocol
    cidr_blocks = [var.db_sg.egress_rules.cidr]
    description = var.db_sg.egress_rules.description
  }
  ingress {
    from_port       = var.db_sg.ingress_rules.from
    to_port         = var.db_sg.ingress_rules.to
    protocol        = var.db_sg.ingress_rules.protocol
    cidr_blocks     = [var.db_sg.ingress_rules.cidr]
    description     = var.db_sg.ingress_rules.description
    security_groups = [aws_security_group.web_sg.id]
  }
}