# CI / Workflows

## Onboarding a new environment or stack

1. **Add the stack to** [`.github/env-stacks.json`](env-stacks.json): add one object per (environment, working_directory), e.g.:
   ```json
   { "environment": "prod", "working_directory": "./env/prod/my-new-stack" }
   ```

2. **Create the environment in GitHub** (if new): **Settings → Environments** → add the name (e.g. `prod`, `staging`). Configure environment-specific secrets (e.g. `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`). Stacks that use DigitalOcean (DOKS, Droplets) need no extra secrets: they look up the DO token by secret name `staging/do-api-token` in AWS Secrets Manager (created by the secrets stack).

3. Plan runs on pull requests to `main`; Apply runs on push to `main`. No workflow file edits needed.

## Workflows

- **Plan** (`plan.yml`): PR to `main` → runs `tofu plan` for every stack in `env-stacks.json`.
- **Apply** (`apply.yml`): Push to `main` → runs `tofu apply` for every stack.
- **Shared** (`shared.yml`): Reusable workflow (init, validate, plan, optional apply) for one stack; used by Plan and Apply via matrix.
