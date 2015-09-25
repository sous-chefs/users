name             "users"
maintainer       "Chef Software, Inc."
maintainer_email "cookbooks@chef.io"
license          "Apache 2.0"
description      "Creates users from a databag search"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.8.4"
source_url       "https://github.com/opscode-cookbooks/users"
issues_url       "https://github.com/opscode-cookbooks/users/issues"
recipe           "users", "Empty recipe for including LWRPs"
recipe           "users::sysadmins", "Create and manage sysadmin group"

%w{ ubuntu debian redhat centos fedora freebsd mac_os_x }.each do |os|
  supports os
end
