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


resource "aws_instance" "app" {
  metadata_options {
    http_tokens = "required"
  }

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name

  tags = {
    Name        = "${var.environment}-app-server"
    Environment = var.environment
    Project     = "aws-enterprise-capstone"
  }
}
