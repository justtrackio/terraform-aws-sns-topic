resource "aws_sns_topic" "main" {
  name = module.this.id
  tags = module.this.tags

  sqs_failure_feedback_role_arn    = var.sqs_failure_feedback_role_arn
  sqs_success_feedback_role_arn    = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate = var.sqs_success_feedback_sample_rate
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "default-account-permissions"
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
      values   = [module.this.aws_account_id]
      variable = "AWS:SourceOwner"
    }
  }

  dynamic "statement" {
    for_each = length(var.principals_with_subscribe_permission) > 0 ? [1] : []
    content {
      sid    = "principals-with-subscribe-permission"
      effect = "Allow"
      principals {
        identifiers = var.principals_with_subscribe_permission
        type        = "AWS"
      }
      actions   = ["SNS:Subscribe"]
      resources = [aws_sns_topic.main.arn]
    }
  }

  dynamic "statement" {
    for_each = length(var.principals_with_publish_permission) > 0 ? [1] : []
    content {
      sid    = "principals-with-publish-permission"
      effect = "Allow"
      principals {
        identifiers = var.principals_with_publish_permission
        type        = "AWS"
      }
      actions   = ["SNS:Publish"]
      resources = [aws_sns_topic.main.arn]
    }
  }
}

resource "aws_sns_topic_policy" "policy" {
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.policy.json
}
