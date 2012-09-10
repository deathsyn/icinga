#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: icinga
# Recipe:: server_source
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

# Package pre-reqs

include_recipe "build-essential"
include_recipe "icinga::client"
include_recipe "php"
include_recipe "php::module_gd"

web_srv = node['icinga']['server']['web_server'].to_sym

case web_srv
when :apache
  include_recipe "icinga::apache"
else
  include_recipe "icinga::nginx"
end

pkgs = value_for_platform(
    ["redhat","centos","fedora","scientific","amazon"] =>
        {"default" => %w{ openssl-devel gd-devel }},
    [ "debian", "ubuntu" ] =>
        {"default" => %w{ libssl-dev libgd2-xpm-dev bsd-mailx}},
    "default" => %w{ libssl-dev libgd2-xpm-dev bsd-mailx }
  )

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

group node['icinga']['group'] do
  members [
    node['icinga']['user'],
    web_srv == :nginx ? node['nginx']['user'] : node['apache']['user']
  ]
  action :modify
end

version = node['icinga']['server']['version']

remote_file "#{Chef::Config[:file_cache_path]}/icinga-#{version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/icinga/icinga-#{version}.tar.gz"
  checksum node['icinga']['server']['checksum']
  action :create_if_missing
end

bash "compile-icinga" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxvf icinga-#{version}.tar.gz
    cd icinga
    ./configure --prefix=/usr \
        --mandir=/usr/share/man \
        --bindir=/usr/sbin \
        --sbindir=/usr/lib/cgi-bin/icinga \
        --datadir=#{node['icinga']['docroot']} \
        --sysconfdir=#{node['icinga']['conf_dir']} \
        --infodir=/usr/share/info \
        --libexecdir=#{node['icinga']['plugin_dir']} \
        --localstatedir=#{node['icinga']['state_dir']} \
        --enable-event-broker \
        --with-icinga-user=#{node['icinga']['user']} \
        --with-icinga-group=#{node['icinga']['group']} \
        --with-command-user=#{node['icinga']['user']} \
        --with-command-group=#{node['icinga']['group']} \
        --with-init-dir=/etc/init.d \
        --with-lockfile=#{node['icinga']['run_dir']}/icinga.pid \
        --with-mail=/usr/bin/mail \
        --with-perlcache \
        --with-htmurl=/icinga \
        --with-cgiurl=/cgi-bin/icinga
    make all
    make install
    make install-init
    make install-config
    make install-commandmode
  EOH
  creates "/usr/sbin/icinga"
end

directory "#{node['icinga']['conf_dir']}/conf.d" do
  owner "root"
  group "root"
  mode 00755
end

%w{ cache_dir log_dir run_dir }.each do |dir|

  directory node['icinga'][dir] do
    owner node['icinga']['user']
    group node['icinga']['group']
    mode 00755
  end

end

directory "/usr/lib/icinga" do
  owner node['icinga']['user']
  group node['icinga']['group']
  mode 00755
end

link "#{node['icinga']['conf_dir']}/stylesheets" do
  to "#{node['icinga']['docroot']}/stylesheets"
end

if web_srv == :apache
  apache_module "cgi" do
    enable :true
  end
end
