# Key Pair
resource "aws_key_pair" "ntier_kp" {
  key_name   = var.ntier_kp.name
  public_key = file(var.ntier_kp.key_path)
}

# Web Server
resource "aws_instance" "webserver_instance" {
  ami                         = var.web_instance_info.ami
  availability_zone           = var.web_instance_info.az
  instance_type               = var.web_instance_info.tier
  key_name                    = aws_key_pair.ntier_kp.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  subnet_id                   = aws_subnet.public_subnet.id
  user_data                   = file("install.sh")
  tags = {
    Name = var.web_instance_info.name
  }
}

# Database Server
resource "aws_instance" "db_instance" {
  ami                    = var.db_instance_info.ami
  availability_zone      = var.db_instance_info.az
  instance_type          = var.db_instance_info.tier
  key_name               = aws_key_pair.ntier_kp.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_id              = aws_subnet.private_subnet.id
  tags = {
    Name = var.db_instance_info.name
  }
}