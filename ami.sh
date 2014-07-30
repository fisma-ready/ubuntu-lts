#!/bin/bash
rm -r ../vendor/cookbooks
berks install --path ../vendor/cookbooks
packer build \
  -var "account_id=$AWS_ACCOUNT_ID" \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
  -var "x509_cert_path=$AWS_X509_CERT_PATH" \
  -var "x509_key_path=$AWS_X509_KEY_PATH" \
  -var "s3_bucket=chef-packer-bucket" \
  packer.json

# Note: to restrict builds to only a specific ami type
# use the following flags in the packer build command
# -only=amazon-ebs
# -only=amazon-instance