#!/bin/bash
rm -rf ../vendor/cookbooks
berks vendor ../vendor/cookbooks
packer build \
  -var "azure_publish_settings_path=$AZURE_PUBLISH_SETTINGS_PATH" \
  -var "azure_subscription_name=$AZURE_SUBSCRIPTION_NAME" \
  -var "azure_storage_account=$AZURE_STORAGE_ACCOUNT" \
  -var "azure_storage_account_container=$AZURE_STORAGE_ACCOUNT_CONTAINER" \
  -var "azure_region=$AZURE_REGION" \
  -var "azure_instance_size=$AZURE_INSTANCE_SIZE" \
  azure/packer-azure.json
