module "example" {
  source = "../.."

  name                             = "my-topic"
  attributes                       = ["test1"]
  alarm_create                     = false
  sqs_failure_feedback_role_arn    = "arn:aws:iam::123456789123:role/SNSDeliveryFeedback"
  sqs_success_feedback_role_arn    = "arn:aws:iam::123456789123:role/SNSDeliveryFeedback"
  sqs_success_feedback_sample_rate = 100
}
