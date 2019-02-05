resource "aws_s3_bucket" "aion" {
  bucket = "aion-${var.aws_region}-${var.environment}"
}

resource "aws_s3_bucket_object" "aion-mainnet" {
  bucket = "${aws_s3_bucket.aion.id}"
  key    = "aion-mainnet.zip"
  source = "aion-mainnet/deploy.zip"
}

resource "aws_s3_bucket_object" "aion-mastery" {
  bucket = "${aws_s3_bucket.aion.id}"
  key    = "aion-mastery.zip"
  source = "aion-mastery/deploy.zip"
}

resource "aws_s3_bucket_object" "pocket" {
  bucket = "${aws_s3_bucket.aion.id}"
  key    = "pocket-node.zip"
  source = "pocket-node/deploy.zip"
}

resource "aws_elastic_beanstalk_application_version" "aion-mainnet" {
  name        = "aion-mainnet"
  application = "${aws_elastic_beanstalk_application.aion-mainnet-node.name}"
  description = "Application version created by terraform for aion-mainnet"
  bucket      = "${aws_s3_bucket.aion.id}"
  key         = "${aws_s3_bucket_object.aion-mainnet.id}"
}

resource "aws_elastic_beanstalk_application_version" "aion-mastery" {
  name        = "aion-mastery"
  application = "${aws_elastic_beanstalk_application.aion-mainnet-node.name}"
  description = "Application version created by terraform for aion-mastery"
  bucket      = "${aws_s3_bucket.aion.id}"
  key         = "${aws_s3_bucket_object.aion-mastery.id}"
}

resource "aws_elastic_beanstalk_application_version" "pocket" {
  name        = "pocket-aion"
  application = "${aws_elastic_beanstalk_application.pocket-node.name}"
  description = "Application version created by terraform for pocket-aion"
  bucket      = "${aws_s3_bucket.aion.id}"
  key         = "${aws_s3_bucket_object.pocket.id}"
}
