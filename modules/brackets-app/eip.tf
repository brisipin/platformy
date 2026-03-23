resource "aws_eip" "app" {
  count  = var.associate_elastic_ip ? 1 : 0
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-eip" })
}

resource "aws_eip_association" "app" {
  count         = var.associate_elastic_ip ? 1 : 0
  instance_id   = aws_instance.app.id
  allocation_id = aws_eip.app[0].id
}
