locals {
  aws_account_id = "123456789123"
  aws_region     = "eu-central-1"
}

module "alarm" {
  source = "../.."

  aws_account_id = local.aws_account_id
  aws_region     = local.aws_region
  name           = "myalarmtopic"
  alarm_enabled  = false
}

module "example1" {
  source = "../.."

  aws_account_id  = local.aws_account_id
  aws_region      = local.aws_region
  name            = "my-topic"
  attributes      = ["test1"]
  alarm_topic_arn = module.alarm.topic_arn
}

module "example2" {
  source = "../.."

  aws_account_id                       = local.aws_account_id
  aws_region                           = local.aws_region
  name                                 = "my-topic"
  attributes                           = ["test2"]
  principals_with_subscribe_permission = ["arn:aws:iam::${local.aws_account_id}:root"]
  principals_with_publish_permission   = ["arn:aws:iam::${local.aws_account_id}:root"]
  alarm_topic_arn                      = module.alarm.topic_arn
}
