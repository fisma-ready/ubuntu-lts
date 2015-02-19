# Ubuntu LTS is FISMA Ready

This project creates both hardened, FISMA Ready Ubuntu LTS Amazon Machine Instances (AMIs) that are suitable for use in Amazon Web Services (AWS) and Virtual Machine images for use in Microsoft Azure. To be FISMA Ready and if deployed to AWS, the AMI must be instantiated in either the US-East, US-West, or GovCloud regions in order to properly inherit the AWS controls assessed by the [FedRAMP program](http://cloud.cio.gov/fedramp). If using Microsoft Azure, the image can be deployed to any region in order to inherit controls defined by FedRAMP. We recommend additional customer level controls on top of the FedRAMP authorization for the AWS or Azure consoles, and we'll be releasing those soon.

We are also working to expand support for other deployment environments and image types.

Prepared and maintained by **[18F](https://18f.gsa.gov)**, a Federal digital services team.

## What this does

### Amazon Web Services

* Takes a **fresh Ubuntu 14.04 LTS AMI ** (`ami-9eaa1cf6`), as published by Canonical:

![1404-lts](docs/ubuntu-1404.png)

* Launches an `m3.medium` instance from this AMI in your AWS account's Classic region (not a VPC).

* Uses the included Chef cookbooks and templates to connect to the instance and configures to controls recommended by the [Center for Internet Security](http://www.cisecurity.org/).

* Creates a new AMI from the configured instance, and prints out the AMI ID.

### Microsoft Azure

* Takes a **daily build of Ubuntu 14.04 LTS** from the Azure VM Image Gallery

* Launches an instance from this image based on a size defined by the `AZURE_INSTANCE_SIZE` environment variable and in to an Azure region defined by the `AZURE_REGION` environment variable.

## Setup

* Install the [Chef Development Kit for your OS](http://downloads.getchef.com/chef-dk/mac/#/). This includes both Knife and [Berkshelf](http://berkshelf.com/), which are critical dependencies.

* Install [Packer for your OS](http://www.packer.io/intro/getting-started/setup.html). For Mac OSX users, we highly recommend using a package manager like [Homebrew](http://brew.sh/) and then running:

```bash
$ brew doctor
$ brew tap homebrew/binary
$ brew install packer
```
At press time, we used Packer 0.7.5

```bash
$ packer version
Packer v0.7.5
```

* In order to deploy to Microsoft Azure, follow the instructions for installing the [packer-azure plugin](https://github.com/MSOpenTech/packer-azure). It is recommended that the REST API implementation of the packer-azure plugin be used vs. the PowerShell wrapper as indicated on the README for that project.

### Amazon Web Services

* Set two environmental variables.

```bash
export AWS_ACCESS_KEY_ID=[your AWS access key]
export AWS_SECRET_ACCESS_KEY=[your AWS secret key]
```

#### Building the AMI

1. Run `ami.sh`.

That's it! Take note of the AMI ID this spits out to your console after it's done.

### Microsoft Azure

* If on Linux, set six environment variables:

```bash
export AZURE_PUBLISH_SETTINGS_PATH="[your Azure publishsettings file path]"
export AZURE_SUBSCRIPTION_NAME="[your Azure Subscription name]"
export AZURE_STORAGE_ACCOUNT="[your Azure Storage Account name]"
export AZURE_STORAGE_ACCOUNT_CONTAINER="[your Azure Storage Account container name]"
export AZURE_REGION="[your chosen Azure region]"
export AZURE_INSTANCE_SIZE="[your Azure VM instance size]"
```

* A helper `azure_env` file has been included for sourcing.

* If on Windows, execute the `azure.ps1` PowerShell script and pass the appropriate values to the parameters.

#### Building the Azure Image

1. Run `azure.ps1` if on Windows or `azure.sh` if on Linux.

### Involvement of 18F

The team at [18F](https://18f.gsa.gov) decided to start work where FedRAMP stops for open source components in a true infrastructure as a service environment - at the operating system layer. Secure baselines were available for Windows, Solaris, and Red Hat Enterprise Linux. But, there were no generally available &mdash; and certainly not public &mdash; baselines, for Ubuntu or the Debian version of Linux generally.

18F is committed to [free and open source software](https://github.com/18F/open-source-policy/blob/master/policy.md) - our intention is that the software we write can be run _anywhere_, without the need to pay for licensing fees.

### Caveat emptor

Our hardened version of Ubuntu is still in *_active development_*. It is subject to change rapidly. Our intention is that no changes will be system breaking, and testing both in local virtual machines and the AWS is ongoing. We have also started to put common web workloads on servers running the hardened OS and no issues have yet arisen. Always use a testing environment before deploying a new OS configuration into production, and please report back with any [Issues](https://github.com/fisma-ready/ubuntu-lts/issues) or [Pull Requests](https://github.com/fisma-ready/ubuntu-lts/pulls).
