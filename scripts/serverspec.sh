#!/bin/bash
set -e
sudo apt-get update
sudo apt-get -y install ruby 
sudo gem install bundler --no-ri --no-rdoc
cd ~/tests
bundle install --path=vendor
sudo bundle exec rake spec
