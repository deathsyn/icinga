#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Kevin Berry <kevin@opensourcealchemist.com>
# Cookbook Name:: icinga
# Library:: default
#
# Copyright 2009, 37signals
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
def icinga_boolean(true_or_false)
  true_or_false ? "1" : "0"
end

def icinga_interval(seconds)
  if seconds.to_i < node['icinga']['interval_length'].to_i
    raise ArgumentError, "Specified icinga interval of #{seconds} seconds must be equal to or greater than the default interval length of #{node['icinga']['interval_length']}"
  end
  interval = seconds / node['icinga']['interval_length']
  interval
end

def icinga_attr(name)
  node['icinga'][name]
end
