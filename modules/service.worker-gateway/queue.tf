resource "aws_sqs_queue" "fifo_queue" {
  fifo_queue                        = true
  name                              = "worker-gateway-message-handler.fifo"
  sqs_managed_sse_enabled           = true
}