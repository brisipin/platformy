# brackets-app

ECR + cheapest Graviton EC2 (`t4g.micro`), **no load balancer**. The app is reachable on the instance **public IP** (optional **Elastic IP** for a stable URL) on `app_port`. API key in Secrets Manager, injected into the container at boot. SQLite on `/opt/brackets-data` → `/data` in the container.

## Container image

- Build **linux/arm64** for `t4g.micro` (e.g. `docker buildx build --platform linux/arm64 ...`).
- Push to the module output `ecr_repository_url` after `aws ecr get-login-password`.
- Image must listen on `app_port` (default 8000).

## FastAPI expectations

- Read `API_KEY` from the environment and reject requests without a matching `X-API-Key` (or `Authorization: Bearer`) header.
- Restrict CORS to your S3 website origin (not `*` in production).

## TLS

Traffic is **HTTP** to the instance. For HTTPS, use a reverse proxy on the box, **Cloudflare** in front of the IP, or another pattern you prefer.

## Network

- Default VPC, first subnet (must route to the internet for pull + clients).
- `allowed_ingress_cidr_blocks` defaults to `0.0.0.0/0`; narrow to your IP or VPN if you can.

## Cost budget (optional)

Set `budget_alert_emails` (non-empty) to create an **AWS Budget** scoped by tag `budget_cost_tag_key` / value (defaults to `App` = value from `tags` or `name_prefix`). Monthly limit defaults to **$50** (`budget_monthly_usd`). Alerts at **80% actual**, **100% actual**, and **100% forecasted**.

In **Billing → Cost allocation tags**, activate the tag key you use (e.g. `App`) so the filter matches spend. Confirm **email subscription** links AWS sends. The IAM principal running OpenTofu needs `budgets:*` (or `budgets:ModifyBudget`, `budgets:ViewBudget`).

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
