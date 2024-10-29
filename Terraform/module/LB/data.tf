data "aws_acm_certificate" "gitfolio_issued" {
    domain = "*.gitfolio.kro.kr"
    statuses = ["ISSUED"]
}