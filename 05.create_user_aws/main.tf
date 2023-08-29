resource "aws_iam_user" "user" {
  name          = var.user_name
  path          = var.user_path
  force_destroy = false
  tags = {
    terraform = true
  }
}

resource "aws_iam_policy" "user_policy" {
  name = var.policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = var.action_for_role_allow
        Effect = "Allow"
        Resource = var.allowing_resources
      },
      # {
      #   Action = var.action_for_role_deny
      #   Effect = "Allow"
      #   Resource = var.denying_resources
      # },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "policy_attach_user" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.user_policy.arn
}

