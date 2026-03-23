locals {
  budget_tag_value_resolved = var.budget_cost_tag_value != "" ? var.budget_cost_tag_value : lookup(var.tags, var.budget_cost_tag_key, var.name_prefix)
  budget_tag_filter_value   = format("%s$%s", var.budget_cost_tag_key, local.budget_tag_value_resolved)
}

resource "aws_budgets_budget" "app" {
  count = var.create_cost_budget && length(var.budget_alert_emails) > 0 ? 1 : 0

  name              = substr(replace("${var.name_prefix}-monthly-cost", "_", "-"), 0, 100)
  budget_type       = "COST"
  limit_amount      = tostring(var.budget_monthly_usd)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = var.budget_time_period_start
  account_id        = data.aws_caller_identity.current.account_id

  cost_filter {
    name   = "TagKeyValue"
    values = [local.budget_tag_filter_value]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }
}
