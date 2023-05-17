locals {
  aws_account_id = "123456789123"
  aws_region     = "eu-central-1"
}

module "example" {
  source = "../.."

  aws_account_id                   = local.aws_account_id
  aws_region                       = local.aws_region
  name                             = "my-topic"
  attributes                       = ["test1"]
  alarm_enabled                    = false
  sqs_failure_feedback_role_arn    = "arn:aws:iam::${local.aws_account_id}:role/SNSDeliveryFeedback"
  sqs_success_feedback_role_arn    = "arn:aws:iam::${local.aws_account_id}:role/SNSDeliveryFeedback"
  sqs_success_feedback_sample_rate = 100
}
