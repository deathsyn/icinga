#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: icinga
# Recipe:: client_source
#
# Copyright 2011, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "build-essential"

pkgs = value_for_platform(
    ["redhat","centos","fedora","scientific","amazon"] =>
        {"default" => %w{ openssl-devel gd-devel }},
    [ "debian", "ubuntu" ] =>
        {"default" => %w{ libssl-dev libgd2-xpm-dev }},
    "default" => %w{ libssl-dev libgd2-xpm-dev }
  )

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

user node['icinga']['user'] do
  system true
end

group node['icinga']['group'] do
  members [ node['icinga']['user'] ]
end

plugins_version = node['icinga']['plugins']['version']

remote_file "#{Chef::Config[:file_cache_path]}/nagios-plugins-#{plugins_version}.tar.gz" do
  source "#{node['icinga']['plugins']['url']}/nagios-plugins-#{plugins_version}.tar.gz"
  checksum node['icinga']['plugins']['checksum']
  action :create_if_missing
end

bash "compile-nagios-plugins" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf nagios-plugins-#{plugins_version}.tar.gz
    cd nagios-plugins-#{plugins_version}
    ./configure --with-nagios-user=#{node['icinga']['user']} \
                --with-nagios-group=#{node['icinga']['group']} \
                --prefix=/usr \
                --libexecdir=#{node['icinga']['plugin_dir']}
    make -s
    make install
  EOH
  creates "#{node['icinga']['plugin_dir']}/check_users"
end

