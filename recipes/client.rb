#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Author:: Kevin Berry <kevin@opensourcealchemist.com>
# Cookbook Name:: icinga
# Recipe:: client
#
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
# Copyright 2012, Kevin Berry
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

mon_host = ['127.0.0.1']

if node.run_list.roles.include?(node['icinga']['server_role'])
  mon_host << node['ipaddress']
elsif node['icinga']['multi_environment_monitoring']
  search(:node, "role:#{node['icinga']['server_role']}") do |n|
   mon_host << n['ipaddress']
  end
else
  search(:node, "role:#{node['icinga']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
    mon_host << n['ipaddress']
  end
end

include_recipe "icinga::client_#{node['icinga']['client']['install_method']}"

remote_directory node['icinga']['plugin_dir'] do
  source "plugins"
  owner "root"
  group "root"
  mode 00755
  files_mode 00755
end
