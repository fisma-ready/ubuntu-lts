#!/bin/bash

# Do we have openssl?
which openssl
if [ $? -ne 0 ]; then
  echo "ERROR: openssl not found. Please ensure an openssl binary is in your \$PATH"
  exit 1
fi

# Create a place for aws ssl certs
if [ ! -d ~/.packer ]; then
  mkdir ~/.packer
fi


KEY_NAME=$1
PEM_NAME="${KEY_NAME}-key.pem"
PEM_NAME_PCKS8="${KEY_NAME}-pem-PCKS8-format.pem"
CERTIFICATE_NAME="${KEY_NAME}-certificate.pem"
openssl genrsa 2048 > ~/.packer/$PEM_NAME
openssl pkcs8 -topk8 -nocrypt -inform PEM -in ~/.packer/$PEM_NAME -out ~/.packer/$PEM_NAME_PCKS8
openssl req -new -x509 -nodes -sha1 -days 365 -key ~/.packer/$PEM_NAME -outform PEM > ~/.packer/$CERTIFICATE_NAME