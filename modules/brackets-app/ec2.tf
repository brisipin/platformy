resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023_arm.id
  instance_type          = var.instance_type
  subnet_id              = local.instance_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  key_name               = aws_key_pair.ec2_ssh.key_name

  associate_public_ip_address = !var.associate_elastic_ip

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    region              = data.aws_region.current.name
    ecr_registry_host   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    ecr_image_uri       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${aws_ecr_repository.app.name}:${var.ecr_image_tag}"
    app_port            = var.app_port
    jwt_secret_arn      = aws_secretsmanager_secret.jwt_secret_key.arn
    cors_allowed_origins = var.create_frontend_hosting ? "https://${aws_cloudfront_distribution.frontend[0].domain_name}" : ""
    data_dir            = "/home/ec2-user/brackets-data"
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  monitoring = true

  tags = merge(var.tags, { Name = "${var.name_prefix}-app" })
}
