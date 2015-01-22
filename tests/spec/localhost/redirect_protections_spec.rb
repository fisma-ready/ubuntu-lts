require 'spec_helper'

describe 'linux kernel parameters' do
  context linux_kernel_parameter('net.ipv4.conf.default.rp_filter') do
    its(:value) {should eq 1}
  end

  context linux_kernel_parameter('net.ipv4.conf.all.rp_filter') do
    its(:value) {should eq 1}
  end

  context linux_kernel_parameter('net.ipv4.conf.all.accept_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv6.conf.all.accept_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.default.accept_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv6.conf.default.accept_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.all.secure_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.default.secure_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.all.send_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.default.send_redirects') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.all.accept_source_route') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv6.conf.all.accept_source_route') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.default.accept_source_route') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv6.conf.default.accept_source_route') do
    its(:value) {should eq 0}
  end

  context linux_kernel_parameter('net.ipv4.conf.all.log_martians') do
    its(:value) {should eq 1}
  end

  context linux_kernel_parameter('net.ipv4.conf.default.log_martians') do
    its(:value) {should eq 1}
  end

end
