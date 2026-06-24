# Rackspace Spot cloudspace nodes have no AWS identity (unlike EKS, there's no
# IRSA / instance-profile path), so pulling from the private teebot ECR repo
# needs a static-credential IAM principal. Scoped to pull-only on this one
# repo. The access key is consumed by an in-cluster CronJob that refreshes a
# Kubernetes imagePullSecret (ECR auth tokens expire every 12h) — see
# sass-bot/deploy/staging.
resource "aws_iam_user" "teebot_ecr_pull" {
  name = "teebot-ecr-pull"
  tags = var.tags
}

resource "aws_iam_user_policy" "teebot_ecr_pull" {
  name = "ecr-pull"
  user = aws_iam_user.teebot_ecr_pull.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "EcrPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Resource = aws_ecr_repository.teebot.arn
      }
    ]
  })
}

resource "aws_iam_access_key" "teebot_ecr_pull" {
  user = aws_iam_user.teebot_ecr_pull.name
}
