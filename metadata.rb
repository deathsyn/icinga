maintainer        "Kevin Berry"
maintainer_email  "kevin@opensourcealchemist.com"
license           "Apache 2.0"
description       "Installs and configures icinga, and plugins on clients"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.3.3"

recipe "icinga", "Includes the client recipe."
recipe "icinga::client", "Installs and configures a icinga client with nrpe"
recipe "icinga::server", "Installs and configures a icinga server"
recipe "icinga::pagerduty", "Integrates contacts w/ PagerDuty API"

%w{ apache2 build-essential php nginx nginx_simplecgi }.each do |cb|
  depends cb
end

%w{ debian ubuntu redhat centos fedora scientific}.each do |os|
  supports os
end
