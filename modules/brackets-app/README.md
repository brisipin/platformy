# brackets-app

ECR + cheapest Graviton EC2 (`t4g.micro`) + ALB. API key in Secrets Manager, injected into the container at boot. SQLite directory on instance disk at `/opt/brackets-data` (mounted to `/data` in the container).

## Container image

- Build **linux/arm64** for `t4g.micro` (e.g. `docker buildx build --platform linux/arm64 ...`).
- Push to the module output `ecr_repository_url` after `aws ecr get-login-password`.
- Image must listen on `app_port` (default 8000).

## FastAPI expectations

- Read `API_KEY` from the environment and reject requests without a matching `X-API-Key` (or `Authorization: Bearer`) header.
- Expose `GET /health` returning 200 for the ALB health check (or set `health_check_path`).
- Restrict CORS to your S3 website origin (not `*` in production).

## HTTPS

Set `certificate_arn` (ACM in the same region as the ALB) to enable TLS on 443 and redirect HTTP to HTTPS.

## New deployment / environment

Copy `env/staging/brackets-app`, change `name_prefix` and backend state key, instantiate the module again.

## GitHub Actions → ECR push (OIDC)

Set `github_actions_ecr_push_repositories` (staging default: `["brisipin/brackets"]`) on the module. Outputs: `ecr_push_role_arn`, `ecr_repository_url`, `aws_account_id`, `aws_region`, `github_oidc_provider_arn`.

If this AWS account has **no** GitHub OIDC provider yet, set `create_github_oidc_provider = true` **once** (or create it manually and pass `github_oidc_provider_arn`).

**App repo workflow** (after apply, copy ARNs/URLs from OpenTofu outputs):

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.ECR_PUSH_ROLE_ARN }}
          aws-region: us-east-2
      - uses: aws-actions/amazon-ecr-login@v2
      - run: |
          docker buildx build --platform linux/arm64 -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG --push .
        env:
          ECR_REGISTRY: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-2.amazonaws.com
          ECR_REPOSITORY: brackets-staging-app
          IMAGE_TAG: ${{ github.sha }}
```

Store `ecr_push_role_arn` in the app repo as `ECR_PUSH_ROLE_ARN`; use the real `ecr_repository_url` / repository name from outputs (`brackets-staging-app` matches `name_prefix` + `-app`).
