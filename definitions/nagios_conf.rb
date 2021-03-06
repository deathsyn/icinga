#
# Author:: Kevin Berry <kberry@opensourcealchemist.com>
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: icinga
# Definition:: icinga_conf
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
define :icinga_conf, :variables => {}, :config_subdir => true do
  
  conf_dir = params[:config_subdir] ? node['icinga']['config_dir'] : node['icinga']['conf_dir']

  template "#{conf_dir}/#{params[:name]}.cfg" do
    owner node['icinga']['user']
    group node['icinga']['group']
    source "#{params[:name]}.cfg.erb"
    mode 0644
    variables params[:variables]
    notifies :reload, "service[icinga]"
    backup 0
  end
end
