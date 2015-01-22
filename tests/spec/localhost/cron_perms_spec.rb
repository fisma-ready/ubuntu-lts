require 'spec_helper'

describe file('/etc/cron.d') do
  it {should be_mode 700}
end

describe file('/etc/cron.daily') do
  it {should be_mode 700}
end

describe file('/etc/cron.hourly') do
  it {should be_mode 700}
end

describe file('/etc/cron.monthly') do
  it {should be_mode 700}
end

describe file('/etc/cron.weekly') do
  it {should be_mode 700}
end

describe file('/etc/crontab') do
  it {should be_mode 700}
end

