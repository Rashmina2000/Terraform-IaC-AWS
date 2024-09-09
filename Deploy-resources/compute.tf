resource "aws_instance" "instance_1" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_1.id
  security_groups = [aws_security_group.instances.id]
  tags = {
    Name = "Machine_1"
  }
  user_data = <<-EOF
              #!/bin/bash
              echo "Greetings from instance 1" > index.html
              python3 -m http.server 80 &
              EOF
}

resource "aws_instance" "instance_2" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_2.id
  security_groups = [aws_security_group.instances.id]
  tags = {
    Name = "Machine_2"
  }
  user_data = <<-EOF
              #!/bin/bash
              echo "Greetings from instance 2" > index.html
              python3 -m http.server 80 &
              EOF
}