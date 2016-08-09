#!/bin/bash
berks vendor cookbooks
packer build \
  -var "aws_access_key_id=$AWS_ACCESS_KEY_ID" \
  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY" \
  -var "grub_passwd=$GRUB_PWD" \
  $1

rm -rf cookbooks
# Note: to restrict builds to only a specific ami type
# use the following flags in the packer build command
# -only=amazon-ebs
# -only=amazon-instance
