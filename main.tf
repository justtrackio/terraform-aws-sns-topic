locals {
  alarm_description = <<EOF
  SNS Topic Dashboard: https://${data.aws_region.main.name}.console.aws.amazon.com/sns/v3/home?region=${data.aws_region.main.name}#/topic/arn:aws:sns:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:${local.sns_topic}
EOF
  sns_topic         = module.this.id
}

module "alarm_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context = module.this.context

  label_order = var.alarm_label_order
}

resource "aws_sns_topic" "main" {
  name = local.sns_topic
  tags = module.this.tags

  sqs_failure_feedback_role_arn    = var.sqs_failure_feedback_role_arn
  sqs_success_feedback_role_arn    = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate = var.sqs_success_feedback_sample_rate
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "default-account-access"
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]
    resources = [aws_sns_topic.main.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.main.account_id]
      variable = "AWS:SourceOwner"
    }
  }

  dynamic "statement" {
    for_each = length(var.principals_with_subscribe_permission) > 0 ? [1] : []
    content {
      sid    = "external-account-access"
      effect = "Allow"
      principals {
        identifiers = var.principals_with_subscribe_permission
        type        = "AWS"
      }
      actions   = ["SNS:Subscribe"]
      resources = [aws_sns_topic.main.arn]
    }
  }
}

resource "aws_sns_topic_policy" "policy" {
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_cloudwatch_metric_alarm" "sns_success_rate" {
  count = var.alarm_create ? 1 : 0

  alarm_description   = local.alarm_description
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
