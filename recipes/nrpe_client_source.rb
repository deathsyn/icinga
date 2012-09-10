#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: icinga
# Recipe:: nrpe_client_source
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

include_recipe "icinga::client_source"

nrpe_version = node['icinga']['nrpe']['version']

remote_file "#{Chef::Config[:file_cache_path]}/nrpe-#{nrpe_version}.tar.gz" do
  source "#{node['icinga']['nrpe']['url']}/nrpe-#{nrpe_version}.tar.gz"
  checksum node['icinga']['nrpe']['checksum']
  action :create_if_missing
end

bash "compile-nrpe" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf nrpe-#{nrpe_version}.tar.gz
    cd nrpe-#{nrpe_version}
    ./configure --prefix=/usr \
                --sysconfdir=/etc \
                --localstatedir=/var \
                --libexecdir=#{node['icinga']['plugin_dir']} \
                --libdir=#{node['icinga']['nrpe']['home']} \
                --enable-command-args
    make -s
    make install
  EOH
  creates "#{node['icinga']['plugin_dir']}/check_nrpe"
end

template "/etc/init.d/nagios-nrpe-server" do
  source "nagios-nrpe-server.erb"
  owner "root"
  group "root"
  mode  00755
end

directory node['icinga']['nrpe']['conf_dir'] do
  owner "root"
  group "root"
  mode  00755
end

