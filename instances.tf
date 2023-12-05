locals {
  patching = {
    amazon_linux = {
      tag         = "amazon-linux"
      description = "Security Patch Tag group to target Amazon Linux instances"
    }
  }
}

resource "aws_key_pair" "patch-example" {
  key_name   = "${var.project}-server-keypair"
  public_key = var.public_key
}

resource "aws_instance" "patch-example" {
  ami                         = "ami-012261b9035f8f938" # Amazon Linux 2023 AMI 2023.2.20231113.0 x86_64 HVM kernel-6.1
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.patch-example.key_name
  iam_instance_profile        = aws_iam_instance_profile.patch-example.name
  associate_public_ip_address = true
  disable_api_termination     = false
  monitoring                  = false

  root_block_device {
    volume_type           = "standard"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name          = var.project
    Project       = var.project
    "Patch Group" = local.patching.amazon_linux.tag
    AutoPatch     = "true"
  }
}