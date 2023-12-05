data "aws_iam_policy_document" "ec2-assume-role-policy-doc" {
  statement {
    sid     = "AssumeServiceRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "patch-example" {
  name               = "PatchExampleRole"
  description        = "Custom role for the Patch Example server"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role-policy-doc.json

  tags = {
    Project = var.project
  }
}

# To attach to the EC2 instance
resource "aws_iam_instance_profile" "patch-example" {
  name = "PatchExampleProfile"
  role = aws_iam_role.patch-example.name
}

resource "aws_iam_role_policy_attachment" "patch-example-ssm-maintenance-window" {
  role       = aws_iam_role.patch-example.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

resource "aws_iam_role_policy_attachment" "patch-example-ssm-managed-instance-core" {
  role       = aws_iam_role.patch-example.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ssm-send-command-policy-doc" {
  statement {
    actions   = ["ssm:SendCommand"]
    effect    = "Allow"
    resources = ["arn:aws:ssm:us-east-1::document/AWS-RunRemoteScript"]
  }
}

resource "aws_iam_role_policy" "patch-example-ssm-send-command-role-policy" {
  name   = "PatchExampleSsmSendCommandRolePolicy"
  role   = aws_iam_role.patch-example.id
  policy = data.aws_iam_policy_document.ssm-send-command-policy-doc.json
}

# Allows running SSM remote commands on EC2 instances
data "aws_iam_role" "aws-service-role-for-amazon-ssm" {
  name = "AWSServiceRoleForAmazonSSM"
}
