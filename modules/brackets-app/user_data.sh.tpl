#!/bin/bash
set -euo pipefail
exec > >(tee /var/log/brackets-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

dnf install -y docker
systemctl enable --now docker

mkdir -p ${data_dir}
chmod 700 ${data_dir}

REGION="${region}"
ECR_URI="${ecr_image_uri}"

aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin ${ecr_registry_host}

API_KEY=$(aws secretsmanager get-secret-value --secret-id "${secret_arn}" --region "$REGION" --query SecretString --output text)

docker pull "$ECR_URI"

docker rm -f brackets-app 2>/dev/null || true
docker run -d --name brackets-app --restart unless-stopped \
  -p ${app_port}:${app_port} \
  -e API_KEY="$API_KEY" \
  -e SQLITE_PATH=/data/app.db \
  -v ${data_dir}:/data \
  "$ECR_URI"
