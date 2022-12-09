variable "alarm_create" {
  type        = bool
  default     = true
  description = "Defines if alarms should be created"
}

variable "alarm_datapoints_to_alarm" {
  type        = number
  default     = 3
  description = "The number of datapoints that must be breaching to trigger the alarm"
}

variable "alarm_evaluation_periods" {
  type        = number
  default     = 3
  description = "The number of periods over which data is compared to the specified threshold"
}

variable "alarm_label_order" {
  type        = list(string)
  description = <<-EOT
    The order in which the labels (ID elements) appear in the `id`.
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.
    EOT
  default     = ["stage", "name"]
}

variable "alarm_period" {
  type        = number
  default     = 60
  description = "The period in seconds over which the specified statistic is applied"
}

variable "alarm_success_rate_threshold" {
  type        = number
  default     = 99
  description = "Required percentage of successful messages"
}

variable "alarm_topic_arn" {
  type        = string
  description = "The ARN of the topic to send alarms to"
  default     = null
}

variable "principals_with_subscribe_permission" {
  type        = list(string)
  description = "ARNs of accounts that are allowed to subscribe e.g. \"arn:aws:iam::123456789123:root\""
  default     = []
}
