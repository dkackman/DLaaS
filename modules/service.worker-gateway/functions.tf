resource "random_uuid" "archive" { }

### START Create Mirror LAMBDA ###

data "archive_file" "create-mirror-function-source" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/create_mirror"
  output_path = "${path.module}/lambdas/create-mirror-tf-handler-${random_uuid.archive.result}.zip"
}

# Upload Lamda function to S3
resource "aws_s3_bucket_object" "create-mirror-function-storage-upload" {
  bucket = var.dev_bucket_id
  key    = "lambdas/create-mirror-tf-handler.zip"
  source = data.archive_file.create-mirror-function-source.output_path
  etag   = filemd5(data.archive_file.create-mirror-function-source.output_path)
}

# Lamda Initialization
resource "aws_lambda_function" "create-mirror-function-handler" {
  function_name     = "create-mirror-handler"
  description       = "${var.aws_profile}: Send Create Mirror Command to Worker"
  s3_bucket         = var.dev_bucket_id
  s3_key            = aws_s3_bucket_object.create-mirror-function-storage-upload.key

  # Entrypoint to lambda function. Format is <file-name>.<property-name>
  handler           = "index.handler"
  runtime           = "nodejs16.x"
  timeout           = 60

  # IAM role for lambda defined below
  role              = var.default_lambda_role_arn
  publish           = true
  source_code_hash  = filebase64sha256(data.archive_file.create-mirror-function-source.output_path)
}

# Give permission to the API gateway to access this lambda
resource "aws_lambda_permission" "create-mirror-api-gateway" {
  statement_id  = "AllowAPIGatewayInvoke"

  # Name of lambda from above
  function_name = aws_lambda_function.create-mirror-function-handler.arn
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"

  # Link to execution arn of API Gateway REST API
  # The "/*/*" portion grants access to any method, any resource within API Gateway
  source_arn    = "${var.api_gateway_arn}/*/*"
}

### END Create Mirror LAMBDA ###