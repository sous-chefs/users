name             'users'
maintainer       'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache-2.0'
description      'Creates users from a databag search'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '5.4.0'

%w( ubuntu debian redhat centos fedora freebsd mac_os_x scientific oracle amazon zlinux suse opensuse opensuseleap aix ).each do |os|
  supports os
end

source_url   'https://github.com/chef-cookbooks/users'
issues_url   'https://github.com/chef-cookbooks/users/issues'
chef_version '>= 12.7' if respond_to?(:chef_version)
