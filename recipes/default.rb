#
# Cookbook Name:: packer
# Recipe:: default

include_recipe 'apt'
include_recipe 'git'

###
# /etc/modprobe.d Safe Defaults
# See https://github.com/18F/ubuntu/blob/master/hardening.md
###
cookbook_file "/etc/modprobe.d/18Fhardened.conf" do
  source "etc/modprobe.d/18Fhardened.conf"
  mode 0644
  owner "root"
  group "root"
end


###
# Redirect protections
# See https://github.com/18F/ubuntu/blob/master/hardening.md#redirect-protections
###
icmp_settings = [
  "net.ipv4.conf.default.rp_filter=1",
  "net.ipv4.conf.all.rp_filter=1",
  "net.ipv4.conf.all.accept_redirects=0",
  "net.ipv6.conf.all.accept_redirects=0",
  "net.ipv4.conf.default.accept_redirects=0",
  "net.ipv6.conf.default.accept_redirects=0",
  "net.ipv4.conf.all.secure_redirects=0",
  "net.ipv4.conf.default.secure_redirects=0",
  "net.ipv4.conf.all.send_redirects=0",
  "net.ipv4.conf.default.send_redirects=0",
  "net.ipv4.conf.all.accept_source_route=0",
  "net.ipv6.conf.all.accept_source_route=0",
  "net.ipv4.conf.default.accept_source_route=0",
  "net.ipv6.conf.default.accept_source_route=0",
  "net.ipv4.conf.all.log_martians=1",
  "net.ipv4.conf.default.log_martians=1"
]
cookbook_file "/etc/sysctl.conf" do
  source "etc/sysctl.conf"
  mode 0644
  owner "root"
  group "root"
end

icmp_settings.each do |icmp_setting|
  execute "update_#{icmp_setting}" do
    command "/sbin/sysctl -w #{icmp_setting}"
    notifies :run, 'execute[flush-sysctl]', :delayed
  end
end
execute 'flush-sysctl' do
  command '/sbin/sysctl -w net.ipv4.route.flush=1 && /sbin/sysctl -w net.ipv6.route.flush=1'
end

###
# Audit Strategy!
# See https://github.com/18F/ubuntu/blob/master/hardening.md#audit-strategy
###

# Time and Space
directory "/etc/audit" do
  owner "root"
  group "root"
  mode 00640
  action :create
end

cookbook_file "/etc/audit/audit.rules" do
  source "etc/audit/audit.rules"
  mode 0640
  owner "root"
  group "root"
end

###
# System Access, Authentication and Authorization
# See https://github.com/18F/ubuntu/blob/master/hardening.md#system-access-authentication-and-authorization
###
file "/etc/at.deny" do
  action :delete
end
file "/etc/cron.allow" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end
file "/etc/at.allow" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end
file "/etc/crontab" do
  owner "root"
  group "root"
  mode "0700"
  action :create
end
crons = [
  "/etc/cron.hourly",
  "/etc/cron.daily",
  "/etc/cron.weekly",
  "/etc/cron.monthly",
  "/etc/cron.d"
]
crons.each do |cron|
  directory "#{cron}" do
    owner "root"
    group "root"
    mode "0700"
    action :create
  end
end

###
# Password Policy
# See https://github.com/18F/ubuntu/blob/master/hardening.md#password-policy
###
package "libpam-cracklib" do
  action :install
end
cookbook_file "/etc/pam.d/common-password" do
  source "etc/pam.d/common-password"
  mode 0644
  owner "root"
  group "root"
end
cookbook_file "/etc/pam.d/login" do
  source "etc/pam.d/login"
  mode 0644
  owner "root"
  group "root"
end
cookbook_file "/etc/login.defs" do
  source "etc/login.defs"
  mode 0644
  owner "root"
  group "root"
end

###
# SSH Settings
# See https://github.com/18F/ubuntu/blob/master/hardening.md#ssh-settings
###
cookbook_file "/etc/ssh/sshd_config" do
  source "etc/ssh/sshd_config"
  mode 0600
  owner "root"
  group "root"
end

###
# Get some banners up and running!
# See https://github.com/18F/ubuntu/blob/master/hardening.md#ssh-settings
###
cookbook_file "/etc/update-motd.d/00-header" do
  source "etc/update-motd.d/00-header"
  mode 0755
  owner "root"
  group "root"
end

###
# Install NTP for better time management
###
apt_package "ntp" do
  action :upgrade # see actions section below
end

###
# Install LVM for partitioning
###
apt_package "lvm2" do
  action :upgrade # see actions section below
end

###
# Partition 
###

cookbook_file "tmp/partitioning.sh" do
  source "config/partitioning.sh"
  mode 0700
  owner "root"
  group "root"
end

execute "partition the second disk" do
  command "bash /tmp/partitioning.sh"
end