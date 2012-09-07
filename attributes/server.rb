#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: icinga
# Attributes:: server
#
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
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

default['icinga']['pagerduty_key'] = ""

case node['platform']
when "ubuntu","debian"
  default['icinga']['server']['install_method'] = 'package'
  default['icinga']['server']['service_name']   = 'icinga'
  default['icinga']['server']['mail_command']   = '/usr/bin/mail'
when "redhat","centos","fedora","scientific","amazon"
  default['icinga']['server']['install_method'] = 'source'
  default['icinga']['server']['service_name']   = 'icinga'
  default['icinga']['server']['mail_command']   = '/bin/mail'
else
  default['icinga']['server']['install_method'] = 'source'
  default['icinga']['server']['service_name']   = 'icinga'
  default['icinga']['server']['mail_command']   = '/bin/mail'
end

default['icinga']['home']       = "/usr/lib/icinga"
default['icinga']['conf_dir']   = "/etc/icinga"
default['icinga']['config_dir'] = "/etc/icinga/objects"
default['icinga']['log_dir']    = "/var/log/icinga"
default['icinga']['cache_dir']  = "/var/cache/icinga"
default['icinga']['state_dir']  = "/var/lib/icinga"
default['icinga']['run_dir']    = "/var/run/icinga"
default['icinga']['docroot']    = "/usr/share/icinga/htdocs"
default['icinga']['enable_ssl'] = false
default['icinga']['http_port']  = node['icinga']['enable_ssl'] ? "443" : "80"
default['icinga']['server_name'] = node.has_key?(:domain) ? "icinga.#{domain}" : "icinga"
default['icinga']['ssl_req'] = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/" +
  "CN=#{node['icinga']['server_name']}/emailAddress=ops@#{node['icinga']['server_name']}"

# for server from source installation
default['icinga']['server']['url']      = 'http://prdownloads.sourceforge.net/sourceforge/icinga'
default['icinga']['server']['version']  = '1.7.2'
default['icinga']['server']['checksum'] = '86497cab06197f6df017e788e26b27bf1797b8c448fa90fa806c693bc30b6750'

default['icinga']['notifications_enabled']   = 0
default['icinga']['check_external_commands'] = true
default['icinga']['default_contact_groups']  = %w(admins)
default['icinga']['sysadmin_email']          = "root@localhost"
default['icinga']['sysadmin_sms_email']      = "root@localhost"
default['icinga']['server_auth_method']      = "openid"

# This setting is effectively sets the minimum interval (in seconds) icinga can handle.
# Other interval settings provided in seconds will calculate their actual from this value, since icinga works in 'time units' rather than allowing definitions everywhere in seconds

default['icinga']['templates'] = Mash.new
default['icinga']['interval_length'] = 1

# Provide all interval values in seconds
default['icinga']['default_host']['check_interval']     = 15
default['icinga']['default_host']['retry_interval']     = 15
default['icinga']['default_host']['max_check_attempts'] = 1
default['icinga']['default_host']['notification_interval'] = 300
default['icinga']['default_host']['flap_detection'] = true

default['icinga']['default_service']['check_interval']     = 60
default['icinga']['default_service']['retry_interval']     = 15
default['icinga']['default_service']['max_check_attempts'] = 3
default['icinga']['default_service']['notification_interval'] = 1200
default['icinga']['default_service']['flap_detection'] = true

default['icinga']['server']['web_server'] = :apache
default['icinga']['server']['nginx_dispatch'] = :cgi
default['icinga']['server']['stop_apache'] = false
