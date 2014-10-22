# Ubuntu LTS is FISMA Ready

This project creates hardened, FISMA Ready Ubuntu LTS Amazon Machine Instances (AMIs) that are suitable for use in Amazon Web Services (AWS). To be FISMA Ready, the AMI must be instantitated in either the US-East or US-West regions of AWS, or the AWS GovCloud, in order to properly inherit the AWS controls assessed by the [FedRAMP program](http://cloud.cio.gov/fedramp). We recommend additional customer level controls on top of the FedRAMP authorization for the AWS Console, and will be releasing those soon.

We are also working to expand support for other deployment environments and image types.

Prepared and maintained by **[18F](https://18f.gsa.gov)**, a Federal digital services team.

## What this does

* Takes a **fresh Ubuntu 14.04 LTS AMI** (`ami-9eaa1cf6`), as published by Canonical:

![1404-lts](docs/ubuntu-1404.png)

* Launches an `m3.medium` instance from this AMI in your AWS account's Classic region (not a VPC).

* Uses the included Chef cookbooks and templates to connect to the instance and configures to controls recommended by the [Center for Internet Security](http://www.cisecurity.org/).

* Creates a new AMI from the configured instance, and prints out the AMI ID.

## Setup

* Install [Packer for your OS](http://www.packer.io/downloads.html). At press time, we used Packer 0.7.1.

```bash
$ packer -v
Packer v0.7.1
```

* Set two environmental variables.

```bash
export AWS_ACCESS_KEY_ID=[your AWS access key]
export AWS_SECRET_ACCESS_KEY=[your AWS secret key]
```

## Building the AMI

1. Run `ami.sh`.

That's it! Take note of the AMI ID this spits out to your console after it's done.
