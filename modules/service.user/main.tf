provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_s3_bucket_object" "job_status_enum_upload" {
  bucket = var.dev_bucket_id
  key    = "configurations/job_status.enum.json"
  content_type = "application/json"
  content = <<EOF
  {  
    "WAITING_FOR_FILE": "WAITING_FOR_FILE",
    "QUEUED": "QUEUED",
    "PROCESSING": "PROCESSING",
    "COMPLETED": "COMPLETED",
    "TRASHED": "TRASHED",
    "FAILED": "FAILED" 
  }
  EOF
}