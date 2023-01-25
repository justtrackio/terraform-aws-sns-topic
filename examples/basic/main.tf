module "alarm" {
  source = "../.."

  name         = "myalarmtopic"
  alarm_create = false
}

module "example1" {
  source = "../.."

  name            = "my-topic"
  attributes      = ["test1"]
  alarm_topic_arn = module.alarm.topic_arn
}

module "example2" {
  source = "../.."

  name                                 = "my-topic"
  attributes                           = ["test2"]
  principals_with_subscribe_permission = ["arn:aws:iam::123456789123:root"]
  principals_with_publish_permission   = ["arn:aws:iam::123456789123:root"]
  alarm_topic_arn                      = module.alarm.topic_arn
}
