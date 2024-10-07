output "website_url" {
  description = "URL of the website"
  value       = aws_s3_bucket_website_configuration.web_bucket_website_configuration.website_endpoint

}
output "cloudfront_distribution_domain_name" {

  value = aws_cloudfront_distribution.cdn.domain_name

  description = "The domain name of the CloudFront distribution"
}
