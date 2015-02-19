param
(
    [Parameter(Mandatory=$true)]
    [string]
    $AzurePublishSettingsPath,

    [Parameter(Mandatory=$true)]
    [string]
    $AzureSubscriptionName,

    [Parameter(Mandatory=$true)]
    [string]
    $AzureStorageAccount,

    [Parameter(Mandatory=$true)]
    [string]
    $AzureStorageAccountContainer,

    [Parameter(Mandatory=$true)]
    [string]
    $AzureRegion,

    [Parameter(Mandatory=$true)]
    [string]
    $AzureInstanceSize
)

if (Test-Path -Path "..\vendor\cookbooks") {
    Remove-Item -Path "..\vendor\cookbooks" -Recurse -Force
}

berks vendor "..\vendor\cookbooks"
packer build `
    -var "azure_publish_settings_path=$AzurePublishSettingsPath" `
    -var "azure_subscription_name=$AzureSubscriptionName" `
    -var "azure_storage_account=$AzureStorageAccount" `
    -var "azure_storage_account_container=$AzureStorageAccountContainer" `
    -var "azure_region=$AzureRegion" `
    -var "azure_instance_size=$AzureInstanceSize" `
    azure\packer-azure.json
