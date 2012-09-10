#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Author:: Kevin Berry <kevin@opensourcealchemist.com>
# Cookbook Name:: icinga
# Recipe:: nrpe_client
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

include_recipe "icinga::client"

directory "#{node['icinga']['nrpe']['conf_dir']}/nrpe.d" do
  owner "root"
  group "root"
  mode 00755
end

template "#{node['icinga']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :mon_host => mon_host,
    :nrpe_directory => "#{node['icinga']['nrpe']['conf_dir']}/nrpe.d"
  )
  notifies :restart, "service[nagios-nrpe-server]"
end

service "nagios-nrpe-server" do
  action [:start, :enable]
  supports :restart => true, :reload => true
end

# Use NRPE LWRP to define a few checks
icinga_nrpecheck "check_load" do
  command "#{node['icinga']['plugin_dir']}/check_load"
  warning_condition node['icinga']['checks']['load']['warning']
  critical_condition node['icinga']['checks']['load']['critical']
  action :add
end

nagios_nrpecheck "check_all_disks" do
  command "#{node['icinga']['plugin_dir']}/check_disk"
  warning_condition "8%"
  critical_condition "5%"
  parameters "-A -x /dev/shm -X nfs -i /boot"
  action :add
end

nagios_nrpecheck "check_users" do
  command "#{node['icinga']['plugin_dir']}/check_users"
  warning_condition "20"
  critical_condition "30"
  action :add
end

