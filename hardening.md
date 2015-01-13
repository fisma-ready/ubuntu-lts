# Hardening Ubuntu 14.04 to 18F standards

This hardening guide, and the operating system (OS) configuration it produces, is in *early beta* and will change. The baseline is currently version 0.1.4. 18F is currently testing this baseline for deployment into production.

There are many recommended controls that are already in place with given a fresh install of either Ubuntu 12.04 LTS or Ubuntu 14.04 LTS. These controls are fully itemized at TBD and are covered by our an open source compliance testing suite we are currently working on.

Controls were implemented on both an Ubuntu 12.04 box downloaded from the [VagrantCloud](https://vagrantcloud.com/hashicorp/precise64/version/2/provider/virtualbox.box) and the default 64-bit Ubuntu 14.04 Amazon Machine Image (AMI).

There might be additional controls necessary for your system at the OS level, above and beyond the following. Please consult with your cybersecurity and DevOps teams.

We strongly encourage the community to help us improve this baseline given an ever-changing risk environment. We believe there is rarely any security in obscurity and that there will always be a greater level of expertise on the outside of team than inside. By doing this work in the open, we will more quickly and effectively identify flaws or potential improvements.

## Before You Start

We've edited this guide to address both the Vagrant and Amazon Web Services (AWS) use cases. As we improve the baseline, we will likely separate the guide based on the deployment environment. For the time being, differences between Vagrant and AWS are noted in-line.

The guide is currently written presuming intermediate familiarity with Linux, the command line, Vagrant/AWS, and system administration in general. References are provided where applicable to provide additional background.

These are controls to implement in a production environment. They may not be currently appropriate for a development environment that is in constant change. Some potential workarounds are discussed at the end of the guide. [TBD]

## Getting Started

First and foremost we'll need a VM to work with.  To do this, we'll start by getting Vagrant installed then use it to abstract away all the complications of spinning up a new VM.

### Vagrant:

[Vagrant](https://www.vagrantup.com/) is a quick, easy way to configure and launch consistent virtual environments across a variety of platforms for test and development. As usual homebrew makes using Vagrant simple for Mac OSX users. 

	brew install vagrant

With vagrant and installed we can start preparing our environment.

	mkdir fisma-ready-ubuntu
	cd fisma-ready-ubuntu
	vagrant init ubuntu/trusty64

Before we can bring a virtual machine online we need one more thing, a [provider](https://docs.vagrantup.com/v2/providers/) for Vagrant to work with. This guide covers both [virtualbox](http://docs.vagrantup.com/v2/virtualbox) for running locally and [aws](https://github.com/mitchellh/vagrant-aws) to launch your machine on Amazon EC2.

#### Virtualbox Provider:

Homebrew comes in handy once again with a little help from the homebrew extension [cask](http://caskroom.io/).

First, we'll add then cask extension.

    brew install caskroom/cask/brew-cask
    
Then we'll use cask to set up virtualbox.

    brew cask install virtualbox
    
Users of other operating systems can find downloads and instructions on for the installation of vagrant and virtualbox at [vagrantup](https://www.vagrantup.com/downloads.html) and [virtualbox](https://www.virtualbox.org/wiki/Downloads) respectively.

##### Additional Configuration - VirtualBox:

Add a second disk and finish configuring your box for use with the virtualbox provider by replacing the contents of the newly created [Vagrantfile](https://docs.vagrantup.com/v2/vagrantfile/)  with the following:

**./Vagrantfile**

	Vagrant.configure(2) do |config|
      config.vm.box = "ubuntu/trusty64"
      config.vm.provider "virtualbox" do | vm |
        file_to_disk = './disks/xvdk.vdi'
        vm.customize ['createhd', 
                      '--filename', file_to_disk, 
                      '--size', 40 * 1024]
        vm.customize ['storageattach', :id, 
                      '--storagectl', 'SATAController', 
                      '--port', 1, 
                      '--device', 0, 
                      '--type', 'hdd', 
                      '--medium', file_to_disk]
      end
    end

This reconfigures the [vagrant box](https://docs.vagrantup.com/v2/boxes.html) we just [initialized](https://docs.vagrantup.com/v2/cli/init.html) to feature a second, 40GB disk which we'll start carving up in just a moment. Don't worry, this new disk won't actually take up 40GB of space. It will only consume as much space as the data data we place on it through the course of this exercise which isn't much.

#### AWS Provider:

Add the aws provider plugin to Vagrant.

	vagrant plugin install vagrant-aws
	
Add the blank 'dummy' box which we'll use as a base for launching into AWS.

	vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

Export your AWS credentials as environment variables.

	export AWS_ACCESS_KEY=YOURAWSACCESSKEY
	export AWS_SECRET_KEY=YOURAWSSECRETKEY

##### Additional Configuration - AWS:
	 
Add a second disk and finish configuring your box for use with the virtualbox provider by replacing the contents of the newly created [Vagrantfile](https://docs.vagrantup.com/v2/vagrantfile/)  with the following.

**./Vagrantfile**

	Vagrant.configure("2") do |config|
	  config.vm.box = "dummy"
	
	  config.vm.provider :aws do |aws, override|
	    aws.keypair_name = "your-keypair-name"
	    aws.ami = "ami-9eaa1cf6"
	    override.ssh.username = "ubuntu"
	    override.ssh.private_key_path = "/path/to/your-keypair-name.pem"
	    aws.tags = {
	      'Name' => 'fisma-ready/ubuntu-lts'
	    }
	    aws.block_device_mapping = [{ 'DeviceName' => '/dev/xvdk', 'Ebs.VolumeSize' => 40 }]
	    aws.security_groups = ['your-security-group-which-allows-ssh']
	  end
	end

There are several placeholder parameters that will need updating.

- *your-keypair-name* - The name of the [AWS keypair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) to use with the instance.

- */path/to/your-keypair-name.pem* - The path and filename of your [AWS private key](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

- *your-security-group-which-allows-ssh* - The name of an EC2 [security group which allows SSH](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html#security-group-rules).

#### Starting Up:

Lets go ahead and start our machine with [vagrant up](https://docs.vagrantup.com/v2/cli/up.html) and connect to it via SSH with [vagrant ssh](https://docs.vagrantup.com/v2/cli/ssh.html).

	vagrant up
	vagrant ssh
	
If all goes well you'll find yourself at the prompt of a fresh Ubuntu 14.04.1 LTS (Trusty) VM.

	vagrant@vagrant-ubuntu-trusty-64:~$

### Preparing the Disk:

Since we created and attached a second disk as part of the Vagrantfile above, there's very little to do here. Just confirm the disk is present.

	sgdisk -p /dev/sdb
	Creating new GPT entries.
	...	
	Total free space is 83886013 sectors (40.0 GiB)
	
	Number  Start (sector)    End (sector)  Size       Code  Name
	vagrant@vagrant-ubuntu-trusty-64:~$ 

#### Device Names:

In the AWS device namespace, it becomes problematic if you occupy the sdb - sde device names. Within your instance, you may see these mapped to xvdb - xvde respectively. In the AWS Provider Vagrantfile above we've mapped our second disk to /dev/xvdk to avoid any potential conflicts. 

The rest of the partition guidance in this section is written from the perspective of the virtualbox provider using device `/dev/sdb`.  If you're running in AWS simply substitute `/dev/xvdk` for `/dev/sdb`.

Determining the last sector also determines how big the partition is. We have 30GB to play with, let's make each 6GB.

	Last sector, +sectors or +size{K,M,G} (2048-52428799, default 52428799): +5G

Hit _p_ to see what happened.

	Command (m for help): p

You should now see _/dev/sdb1_ listed!

Rinse and repeat until you have _sdb1_ -> _sdb4_ in the dialog listed by the _p_ command. *Warning:* you have to write this config to disk! Hit _w_.

	Command (m for help): w

This will also exit _fdisk_. Let's take a last look to confirm our work:

	fdisk -l

	(...)

	   Device Boot      Start         End      Blocks   Id  System
	/dev/sdb1            2048    10487807     5242880   83  Linux
	/dev/sdb2        10487808    20973567     5242880   83  Linux
	/dev/sdb3        20973568    31459327     5242880   83  Linux
	/dev/sdb4        31459328    41945087     5242880   83  Linux

Looks great! But all that's happened is that you've created device listing within the OS. Ubuntu still doesn't think these are physical volumes ready for use.

### Using LVM to finish the job.

Reference: [A Beginner's Guide To LVM](http://www.howtoforge.com/linux_lvm)

The Logical Volume Management (LVM) app can take these devices and make partitions. The first step is to create physical volumes (PV).

	pvcreate /dev/xvdb1 /dev/xvdb2 /dev/xvdb3 /dev/xvdb4

Check your work.

	pvdisplay

Now we can create a volume group (VG) to contain our logical volumes (LV). We need to give our VG a name - securefolders.

	vgcreate securefolders /dev/xvdb1 /dev/xvdb2 /dev/xvdb3 /dev/xvdb4

If this is confusing, check out this diagram from [Wikipedia](http://en.wikipedia.org/wiki/File:LVM1.svg) and this [StackExchange article](http://unix.stackexchange.com/questions/87300/differences-between-volume-partition-and-drive)

The order of abstraction is PV > VG > LV.

Make a logical volume - this is the last abstraction, and where we will actually mount our folders. I'll begin with a LV for /tmp, which I'll call _temp_.

	lvcreate --name temp --size 5G securefolders

If you go back and look at _vgdisplay_ at this point, you should see that your _Free PE_ has now dropped.

Abstractions are over, so let's get an actual filesystem going! At the moment, _ext4_ is the latest and greatest, so we'll use that.

	mkfs.ext4 /dev/securefolders/temp

We now have some [safety checks](https://help.ubuntu.com/community/Partitioning/Home/Moving) before we start mounting. A key configuration file _fstab_ will be altered, so let's make a backup.

	cp /etc/fstab /etc/fstab.$(date +%Y-%m-%d)

To be extra careful, let's make a backup of all the files we're going to re-mount. I've heard rsync can preserve permissions better than _cp_. Go to the top level and make some backupfolders first.

	mkdir homeBackup
	mkdir varBackup
	rsync -aXS /home/* /homeBackup
	rsync -aXS /var/* /varBackup

Ok, we _finally_ have a thing we can mount to! Let's tackle /tmp first.

	 mount /dev/securefolders/temp /tmp
	 df -H

	Filesystem                      Size  Used Avail Use% Mounted on
	/dev/mapper/precise64-root       79G  2.2G   73G   3% /
	udev                            174M  4.0K  174M   1% /dev
	tmpfs                            74M  308K   73M   1% /run
	none                            5.0M     0  5.0M   0% /run/lock
	none                            183M     0  183M   0% /run/shm
	/dev/sda1                       228M   25M  192M  12% /boot
	/vagrant                        233G  169G   65G  73% /vagrant
	/dev/mapper/securefolders-temp   10G  280M  9.2G   3% /tmp


### Secure filesystem configuration

Let's put some security options on that folder.

	mount -o remount,nodev,nosuid,noexec /tmp

But what happens if we reboot? We don't want to deal with creating a shell script for this. This should be in the baseline. There's a file called _fstab_ that will cover it for us.

	vi /etc/fstab

Go to the end and add the following.

	/dev/securefolders/temp   /tmp   ext4   defaults,rw,nodev,nosuid,noexec   0   2

Nice - after a reboot, everything will mount correctly with your new security options.

With all the concepts in the clear let's bundle things up for the other assets that will be in _securefolders_ VG.

	lvcreate --name variables --size 5G securefolders
	lvcreate --name audits --size 5G securefolders
	lvcreate --name house --size 5G securefolders

	mkfs.ext4 /dev/securefolders/variables
	mkfs.ext4 /dev/securefolders/audits
	mkfs.ext4 /dev/securefolders/house

Let's break things up here. First, get _/var_ mounted.

	mount /dev/securefolders/variables /var

Pausing here, we want to bind mount _/var/tmp_ to _/tmp_. Beyond inheriting previous security modifications of _/tmp_, this keeps things tidy.

Since we still have the new OS smell, _/var/tmp_ _may_ not exist yet. Same with _/var/log/audit_. We'll make them both and do necessary binding.

	cd var
	mkdir /var/tmp
	mount --bind /tmp /var/tmp
	mkdir log
	cd log
	mkdir audit

Check your binding.

	mount | grep -e "^/tmp" | grep /var/tmp

Just like everything else, we need to modify our _/etc/fstab_ to have this persist beyond a reboot.

We'll add the following:

	/tmp /var/tmp none bind 0 0

Finish up the mounting.

	mount /dev/securefolders/audits /var/log/audit
	mount /dev/securefolders/house /home

Look under the hood.

	df -H

	(...)
	/dev/mapper/securefolders-temp       5.4G  214M  4.9G   5% /tmp
	/dev/mapper/securefolders-house      5.4G  214M  4.9G   5% /home
	/dev/mapper/securefolders-variables  5.4G  682M  4.5G  14% /var
	/dev/mapper/securefolders-audits     5.4G  214M  4.9G   5% /var/log/audit

One more secure modification in this area - see _/run/shm_ above? That powers part of the temporary filesystem. Let's lock it down.

	mount -o remount,noexec,nosuid,nodev /run/shm

One more edit to _/etc/fstab_ to bake it in. Add:

	none   /run/shm   tmpfs   defaults,nodev,noexec,nosuid   0   0

### Reduce attack surface

References: _**Need to find some**_

Every installed application creates an potential attack surface. A hardened OS reduces this surface to the absolute minimum for system functionality.

One of the places we can reduce the attack surface is in a configuration file stored in _/etc/modprobe.d_

	cd /etc/modprobe.d
	touch 18Fhardened.conf
	vi 18Fhardened.conf

Add:

	#Applications

	install cramfs /bin/true
	install freevxfs /bin/true
	install jffs2 /bin/true
	install hfs /bin/true
	install hfsplus /bin/true
	install squashfs /bin/true
	install udf /bin/true

	# Protocols

	install dccp /bin/true
	install sctp /bin/true
	install rds /bin/true
	install tipc /bin/true

## Boot settings

References: [Ubuntu and GRUB](http://ubuntuforums.org/archive/index.php/t-1369019.html)

Boot loaders need to be protected. Anyone who is not _root_ doesn't need to write to this file. Likely everything is already in order, but just to be sure:

	chmod og-wx /boot/grub/grub.cfg

We don't want anyone messing with booting, so let's create a password.

	grub-mkpasswd-pbkdf2

Be sure to keep this password somewhere safe. You'll also get an encrypted version of the password. Hang on to it as we need to jump in to configuration settings again.

	vim /etc/grub.d/40_custom

Add:

	set superusers="INSERT USER HERE"
	password_pbkdf2 INSERT USER HERE <encrypted-password>
	EOF

Sub out _<encrypted-password>_ with the actual value you just got, otherwise the next command will fail. This is the value that starts with _grub.pbkdf2.sha512_

Save the file and then use:

	update-grub

## Redirect protections

Unless this OS is powering a router, we can harden how it handles ICMP redirects.

_/etc/sysctl.conf_ controls these settings.

	vim /etc/sysctl.conf

You'll find all the controls already here, but commented out. You'll want to remove the _#_ for the following, or add these lines if they're not there:

	# Spoof protection
	net.ipv4.conf.default.rp_filter=1
	net.ipv4.conf.all.rp_filter=1

	# Do not accept ICMP redirects (prevent MITM attacks)
	net.ipv4.conf.all.accept_redirects=0
	net.ipv6.conf.all.accept_redirects=0
	net.ipv4.conf.default.accept_redirects=0
	net.ipv6.conf.default.accept_redirects=0
	net.ipv4.conf.all.secure_redirects=0
	net.ipv4.conf.default.secure_redirects=0

	# Do not send ICMP redirects (we are not a router)
	net.ipv4.conf.all.send_redirects=0
	net.ipv4.conf.default.send_redirects=0

	# Do not accept IP source route packets (we are not a router)
	net.ipv4.conf.all.accept_source_route=0
	net.ipv6.conf.all.accept_source_route=0
	net.ipv4.conf.default.accept_source_route=0
	net.ipv6.conf.default.accept_source_route=0

	# Log packets from Mars
	net.ipv4.conf.all.log_martians=1
	net.ipv4.conf.default.log_martians=1

Update your kernel parameters to match - for each of these lines enter:

	/sbin/sysctl -w [INSERT LINE HERE W/ VALUE]

Then, flush!

	/sbin/sysctl -w net.ipv4.route.flush=1
	/sbin/sysctl -w net.ipv6.route.flush=1

## Audit strategy

Reference: [Notes about auditing configuration](http://konstruktoid.net/2014/04/29/hardening-the-ubuntu-14-04-server-even-further/)

Audit strategy is highly environment and application specific. In the near future, we will post some overall best practices here, liley including a more standardized configuration for _/etc/audit/auditd.conf_

### Booting

_auditd_ is great, but it can't audit processes that run before it starts - or *can it*?

	vi /etc/default/grub

Then modify the following line to read:

	GRUB_CMDLINE_LINUX="audit=1"

run:

	update-grub

### Time and space

By default, you won't capture audit events when a user changes system date and time, or when users change user accts or passwords. This ain't no TARDIS and you're no Doctor. Let's capture those events by modifying _/etc/audit/audit.rules_.

	vi /etc/audit/audit.rules

Add:

Date/time:

	-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
	-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
	-a always,exit -F arch=b64 -S clock_settime -k time-change
	-a always,exit -F arch=b32 -S clock_settime -k time-change
	-w /etc/localtime -p wa -k time-change


User/passwords:

	-w /etc/group -p wa -k identity
	-w /etc/passwd -p wa -k identity
	-w /etc/gshadow -p wa -k identity
	-w /etc/shadow -p wa -k identity
	-w /etc/security/opasswd -p wa -k identity


Network stuff:

	-a exit,always -F arch=b64 -S sethostname -S setdomainname -k system-locale
	-a exit,always -F arch=b32 -S sethostname -S setdomainname -k system-locale
	-w /etc/issue -p wa -k system-locale
	-w /etc/issue.net -p wa -k system-locale
	-w /etc/hosts -p wa -k system-locale
	-w /etc/network -p wa -k system-locale

SELinux (likely you're using AppArmor instead, but just in case you pull SELinux packages from Debian, best to have this already listed)

	-w /etc/selinux/ -p wa -k MAC-policy

Login and logout:

	-w /var/log/faillog -p wa -k logins
	-w /var/log/lastlog -p wa -k logins
	-w /var/log/tallylog -p wa -k logins

Permission modifications:

	-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod
	-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod
	-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
	-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=500 -F auid!=4294967295 -k perm_mod
	-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod
	-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod

Unauthorized access:

	-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
	-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
	-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access
	-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access

Collect filesystem mounts:

	-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts
	-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts

File deletion:

	-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete
	-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete

Change to sysadmin scope:

	-w /etc/sudoers -p wa -k scope

Kernel loading:

	-w /sbin/insmod -p x -k modules
	-w /sbin/rmmod -p x -k modules
	-w /sbin/modprobe -p x -k modules
	-a always,exit arch=b64 -S init_module -S delete_module -k modules

Make audit config immutable

	-e 2

## System Access, Authentication and Authorization

Only root should modify what system jobs cron runs.

	chown root:root /etc/crontab
	chmod og-rwx /etc/crontab

	chown root:root /etc/cron.hourly
	chmod og-rwx /etc/cron.hourly

	chown root:root /etc/cron.daily
	chmod og-rwx /etc/cron.daily

	chown root:root /etc/cron.weekly
	chmod og-rwx /etc/cron.weekly

	chown root:root /etc/cron.monthly
	chmod og-rwx /etc/cron.monthly

	chown root:root /etc/cron.d
	chmod og-rwx /etc/cron.d

It's easier to manage a whitelist then a blacklist. Make the following additional modifications.

[As an aside, this guidance is a little off IMHO. If neither *.deny or *.allow files exist, access is automatically restricted to root. In the case of cron, this is how Ubuntu 14L is right out of the box.]

	/bin/rm /etc/at.deny
	touch /etc/cron.allow
	touch /etc/at.allow

Modify both files so they have "root" listed. Then:

	chmod og-rwx /etc/cron.allow
	chmod og-rwx /etc/at.allow
	chown root:root /etc/cron.allow
	chown root:root /etc/at.allow

## Password policy

Script-kiddies and crackers should find no safe harbor here. Let's prevent common cracking by improving our password polcies.

Install a helpful module:

	apt-get install libpam-cracklib

This module will automatically add a line to /etc/pam.d/common-password with some default settings. It will read:

	password     requisite     pam_cracklib.so retry=3 minlen=8 difok=3

Our current recommended settings are more stringent. Let's also remove difok - it's ok if characters from old passswords repeat as long as there is significant entropy.

	password     requisite     pam_cracklib.so retry=3 minlen=24 dcredit=-2 ucredit=-2 ocredit=-2 lcredit=-2

We can prevent password reuse by adding remember=5 to the next line:

	password     [success=1 default=ignore]     pam_unix.so obscure use_authtok try_first_pass sha512 remember=5

Lockouts /etc/pam.d/login

	auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900

Password expiration using /etc/login.defs

	PASS_MAX_DAYS 90
	PASS_MIN_DAYS 7
	PASS_WARN_AGE 10

## SSH Settings

Modify a file at...

	/etc/ssh/sshd_config

	X11Forwarding no
	MaxAuthTries 4
	PermitRootLogin no
	PermitEmptyPasswords no
	PermitUserEnvironment no
	Ciphers aes128-ctr,aes192-ctr,aes256-ctr
	ClientAliveInterval 600
	ClientAliveCountMax 0

Lock the file permissions down:

	chown root:root /etc/ssh/sshd_config
	chmod 600 /etc/ssh/sshd_config

## Banners

Add one then correct permissions

	chmod 644 /etc/motd
	chmod 644 /etc/issue
	chmod 644 /etc/issue.net

### Appendix

Modified config files

	/etc/default/grub
	/etc/audit/audit.rules
	/etc/sysctl.conf
	/etc/pam.d/common-password
	/etc/pam.d/login
	/etc/ssh/sshd_config
	/etc/login.defs

#### Misc

Questions? Email noah.kunin@gsa.gov.
