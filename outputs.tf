output "topic_arn" {
  description = "ARN of the topic"
  value       = aws_sns_topic.main.arn
}
