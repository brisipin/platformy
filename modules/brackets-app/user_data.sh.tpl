#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/brackets-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

dnf install -y docker
systemctl enable --now docker

mkdir -p ${data_dir}
chmod 700 ${data_dir}

REGION="${region}"
IMAGE="${ecr_image_uri}"

aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin ${ecr_registry_host}

JWT_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id "${jwt_secret_arn}" \
  --region "$REGION" \
  --query SecretString --output text)

docker pull "$IMAGE"

docker rm -f brackets-api 2>/dev/null || true

docker run -d \
  --name brackets-api \
  --restart unless-stopped \
  -p ${app_port}:${app_port} \
  -v ${data_dir}:/app/data \
  -e DATABASE_URL="sqlite:////app/data/bracket.db" \
  -e BRACKET_DATABASE_URL="sqlite+aiosqlite:////app/data/bracket.db" \
  -e JWT_SECRET_KEY="$JWT_SECRET" \
  -e COOKIE_SECURE="true" \
  -e CORS_ALLOWED_ORIGINS="${cors_allowed_origins}" \
  "$IMAGE" \
  sh -c "([ -f /app/data/bracket.db ] || litestream restore -config /etc/litestream.yml -if-replica-exists /app/data/bracket.db) && alembic upgrade head && litestream replicate -config /etc/litestream.yml -exec 'uvicorn main:app --host 0.0.0.0 --port ${app_port}'"
