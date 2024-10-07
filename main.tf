#terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#declare the provider to use
provider "aws" {
  region = var.aws_region
}

#hashicorp module to upload object to s3 bucket
module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/bootcamp-1-project-1a"
}

#bucket resource
resource "aws_s3_bucket" "web_bucket" {
  bucket = var.bucket_name
}
#bucket policy and acls
resource "aws_s3_bucket_public_access_block" "web_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.web_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

#resource "aws_s3_bucket_acl" "web_bucket_acl" {
#  bucket = aws_s3_bucket.web_bucket.id
#  acl    = "public-read"
#}

#bucket policy in json
resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = aws_s3_bucket.web_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}

#bucket configuration for Static Website
resource "aws_s3_bucket_website_configuration" "web_bucket_website_configuration" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.index.html"
  }
}

#upload files to s3 bucket
resource "aws_s3_object" "web_bucket_files" {
  bucket = aws_s3_bucket.web_bucket.id

  for_each = module.template_files.files

  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content
  etag    = each.value.digests.md5
}
