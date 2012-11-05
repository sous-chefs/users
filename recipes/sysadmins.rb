#
# Cookbook Name:: users
# Recipe:: sysadmins
#
# Copyright 2011, Eric G. Wolfe
# Copyright 2009-2011, Opscode, Inc.
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

# Searches data bag "users" for groups attribute "sysadmin".
# Places returned users in Unix group "sysadmin" with GID 2300.

case node['platform']
when "ubuntu","debian"
  update = execute "apt-get update" do
    action :nothing
  end

  update.run_action(:run)

  %w{build-essential binutils-doc}.each do |pkg|
    to_install = package pkg do
      action :nothing
    end
    to_install.run_action(:install)
  end
when "centos","redhat","fedora","amazon"
  %w{gcc gcc-c++ kernel-devel make}.each do |pkg|
    to_install = package pkg do
      action :nothing
      not_if 'which gcc > /dev/null'
    end
    to_install.run_action(:install)
  end
end

chef_gem "ruby-shadow"

users_manage "sysadmin" do
  group_id 2300
  action [ :remove, :create ]
end

users_manage "adm" do
  group_id 4
  action [ :remove, :create ]
end
