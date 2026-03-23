output "bucket_name" {
  value = aws_s3_bucket.opentofu_state.id
}

output "bucket_arn" {
  value = aws_s3_bucket.opentofu_state.arn
}

output "region" {
  value = aws_s3_bucket.opentofu_state.region
}
