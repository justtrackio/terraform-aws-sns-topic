locals {
  alarm_description = var.alarm_description != null ? var.alarm_description : "SNS Topic Dashboard: https://${var.aws_region}.console.aws.amazon.com/sns/v3/home?region=${var.aws_region}#/topic/arn:aws:sns:${var.aws_region}:${var.aws_account_id}:${module.this.id}"
}

module "alarm_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context

  label_order = var.label_orders.cloudwatch
}

resource "aws_cloudwatch_metric_alarm" "sns_success_rate" {
  count = var.alarm_create ? 1 : 0

  alarm_description = jsonencode(merge({
    Severity    = "warning"
    Description = local.alarm_description
  }, module.this.tags, module.this.additional_tag_map))
  alarm_name          = "${module.alarm_label.id}-${join("", module.this.attributes)}-sns-success-rate"
  comparison_operator = "LessThanThreshold"
  datapoints_to_alarm = var.alarm_datapoints_to_alarm
  evaluation_periods  = var.alarm_evaluation_periods
  tags                = module.this.tags
  threshold           = var.alarm_success_rate_threshold
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "published"
    return_data = false

    metric {
      dimensions = {
        TopicName = aws_sns_topic.main.name
      }
      metric_name = "NumberOfMessagesPublished"
      namespace   = "AWS/SNS"
      period      = var.alarm_period
      stat        = "Sum"
    }
  }

  metric_query {
    id          = "failed"
    return_data = false

    metric {
      dimensions = {
        TopicName = aws_sns_topic.main.name
      }
      metric_name = "NumberOfNotificationsFailed"
      namespace   = "AWS/SNS"
      period      = var.alarm_period
      stat        = "Sum"
    }
  }

  metric_query {
    expression  = "100-100*(failed/published)"
    id          = "e1"
    label       = "100-100*(failed/published)"
    return_data = true
  }

  alarm_actions = [var.alarm_topic_arn]
  ok_actions    = [var.alarm_topic_arn]
}
