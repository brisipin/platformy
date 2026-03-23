resource "aws_iam_openid_connect_provider" "github" {
  count = length(var.github_actions_ecr_push_repositories) > 0 && var.create_github_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  tags            = var.tags
}

data "aws_iam_openid_connect_provider" "github" {
  count = length(var.github_actions_ecr_push_repositories) > 0 && var.github_oidc_provider_arn == "" && !var.create_github_oidc_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_ecr_push" {
  count = length(var.github_actions_ecr_push_repositories) > 0 ? 1 : 0

  name_prefix = "${var.name_prefix}-gh-ecr-"
  description = "GitHub Actions OIDC can assume this role to push images to the brackets ECR repo."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = local.github_oidc_provider_arn_resolved
      }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = local.github_oidc_subject_patterns
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "github_ecr_push" {
  count = length(var.github_actions_ecr_push_repositories) > 0 ? 1 : 0

  name_prefix = "ecr-push-"
  role        = aws_iam_role.github_ecr_push[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.app.arn
      }
    ]
  })
}
