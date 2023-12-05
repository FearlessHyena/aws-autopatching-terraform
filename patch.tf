# Auto Patch all targeted instances running Amazon Linux 2023
resource "aws_ssm_patch_baseline" "patch-example" {
  name             = "patch-example-baseline"
  description      = "Amazon Linux 2023 Patch Baseline"
  operating_system = "AMAZON_LINUX_2023"
  approval_rule {
    enable_non_security = false # Set to true to install non-security updates
    approve_after_days  = 7
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["*"]
    }
  }
}

resource "aws_ssm_patch_group" "patch-example" {
  baseline_id = aws_ssm_patch_baseline.patch-example.id
  patch_group = local.patching.amazon_linux.tag
}

resource "aws_ssm_maintenance_window" "patch-example" {
  name        = "patch-example-maintenance-install"
  schedule    = "cron(0 0 ? * SUN *)" # Every Sunday at 12 AM UTC
  description = local.patching.amazon_linux.description
  duration    = 3
  cutoff      = 1
}

resource "aws_ssm_maintenance_window_target" "patch-example" {
  window_id     = aws_ssm_maintenance_window.patch-example.id
  resource_type = "INSTANCE"
  description   = local.patching.amazon_linux.description

  targets {
    key    = "tag:Patch Group"
    values = [local.patching.amazon_linux.tag]
  }
}

resource "aws_ssm_maintenance_window_task" "patch-example" {
  window_id        = aws_ssm_maintenance_window.patch-example.id
  description      = local.patching.amazon_linux.description
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = data.aws_iam_role.aws-service-role-for-amazon-ssm.arn
  max_concurrency  = "100%"
  max_errors       = "100%"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch-example.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment          = "Amazon Linux 2023 Patch Baseline Install"
      document_version = "$LATEST"
      timeout_seconds  = 3600
      cloudwatch_config {
        cloudwatch_log_group_name = aws_cloudwatch_log_group.patch-example.id
        cloudwatch_output_enabled = true
      }
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "patch-example" {
  name              = var.project
  retention_in_days = 7
  tags = {
    Project = var.project
  }
}

# Auto Update SSM agents on existing instances
resource "aws_ssm_association" "patch-example-ssm-agent-update" {
  name                = "AWS-UpdateSSMAgent"
  association_name    = "CustomAutoUpdateSSMAgent"
  schedule_expression = "cron(0 0 ? * SAT *)" // Every Saturday at 12 AM UTC */
  max_concurrency     = "100%"
  max_errors          = "100%"

  targets {
    key    = "tag:AutoPatch"
    values = ["true"]
  }
}



