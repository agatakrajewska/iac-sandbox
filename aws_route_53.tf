resource "aws_route53_zone" "example" {
  name = "snyk-example.com"
}

resource "aws_route53_zone" "example_2" {
  name = "snyk-example.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.example.id
  name    = "www.snyk-example.com"
  type    = "CNAME"
  ttl     = 300
  records = ["dev.snyk-example.com"]
}

resource "aws_route53_record" "www_2" {
  zone_id = aws_route53_zone.example_2.id
  name    = "www.snyk-example.com"
  type    = "CNAME"
  ttl     = 300
  records = ["dev.snyk-example.com"]
}