#
# Cookbook Name:: users
# Provider:: manage
#
# Copyright 2011, Eric G. Wolfe
# Copyright 2009-2016, Chef Software, Inc.
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

use_inline_resources

def whyrun_supported?
  true
end

action :remove do
  search(new_resource.data_bag, "groups:#{new_resource.search_group} AND action:remove") do |rm_user|
    user rm_user['username'] ||= rm_user['id'] do
      action :remove
      force rm_user['force'] ||= false
    end
  end
end

action :create do
  users_groups = {}
  users_groups[new_resource.group_name] = []

  search(new_resource.data_bag, "groups:#{new_resource.search_group} AND NOT action:remove") do |u|
    u['username'] ||= u['id']
    u['groups'].each do |g|
      users_groups[g] = [] unless users_groups.key?(g)
      users_groups[g] << u['username']
    end

    if node['apache'] && node['apache']['allowed_openids']
      Array(u['openid']).compact.each do |oid|
        node.default['apache']['allowed_openids'] << oid unless node['apache']['allowed_openids'].include?(oid)
      end
    end

    # Platform specific checks
    #  Set home_basedir
    #  Set shell on FreeBSD
    home_basedir = '/home'

    case node['platform_family']
    when 'mac_os_x'
      home_basedir = '/Users'
    when 'freebsd'
      # Check if we need to prepend shell with /usr/local/?
      u['shell'] = (!::File.exist?(u['shell']) && ::File.exist?("/usr/local#{u['shell']}") ? "/usr/local#{u['shell']}" : '/bin/sh')
    end

    # Set home to location in data bag,
    # or a reasonable default ($home_basedir/$user).
    home_dir = (u['home'] ? u['home'] : "#{home_basedir}/#{u['username']}")

    # check whether home dir is null
    manage_home = (home_dir == '/dev/null' ? false : true)

    # The user block will fail if the group does not yet exist.
    # See the -g option limitations in man 8 useradd for an explanation.
    # This should correct that without breaking functionality.
    group u['username'] do # ~FC022
      gid validate_id(u['gid'])
      only_if { u['gid'] && u['gid'].is_a?(Numeric) }
    end

    # Create user object.
    # Do NOT try to manage null home directories.
    user u['username'] do
      uid validate_id(u['uid'])
      gid validate_id(u['gid']) if u['gid']
      shell u['shell']
      comment u['comment']
      password u['password'] if u['password']
      salt u['salt'] if u['salt']
      iterations u['iterations'] if u['iterations']
      manage_home manage_home
      home home_dir
      action u['action'] if u['action']
    end

    if manage_home_files?(home_dir, u['username'])
      Chef::Log.debug("Managing home files for #{u['username']}")

      directory "#{home_dir}/.ssh" do
        recursive true
        owner u['uid'] ? validate_id(u['uid']) : u['username']
        group validate_id(u['gid']) if u['gid']
        mode '0700'
        only_if { u['ssh_keys'] || u['ssh_private_key'] || u['ssh_public_key'] }
      end

      template "#{home_dir}/.ssh/authorized_keys" do
        source 'authorized_keys.erb'
        cookbook new_resource.cookbook
        owner u['uid'] ? validate_id(u['uid']) : u['username']
        group validate_id(u['gid']) if u['gid']
        mode '0600'
        variables ssh_keys: u['ssh_keys']
        only_if { u['ssh_keys'] }
      end

      if u['ssh_private_key']
        key_type = u['ssh_private_key'].include?('BEGIN RSA PRIVATE KEY') ? 'rsa' : 'dsa'
        template "#{home_dir}/.ssh/id_#{key_type}" do
          source 'private_key.erb'
          cookbook new_resource.cookbook
          owner u['uid'] ? validate_id(u['uid']) : u['username']
          group validate_id(u['gid']) if u['gid']
          mode '0400'
          variables private_key: u['ssh_private_key']
        end
      end

      if u['ssh_public_key']
        key_type = u['ssh_public_key'].include?('ssh-rsa') ? 'rsa' : 'dsa'
        template "#{home_dir}/.ssh/id_#{key_type}.pub" do
          source 'public_key.pub.erb'
          cookbook new_resource.cookbook
          owner u['uid'] ? validate_id(u['uid']) : u['username']
          group validate_id(u['gid']) if u['gid']
          mode '0400'
          variables public_key: u['ssh_public_key']
        end
      end
    else
      Chef::Log.debug("Not managing home files for #{u['username']}")
    end
  end

  # Populating users to appropriates groups
  users_groups.each do |g, u|
    group g do
      members u
      append true
      action :manage # Do nothing if group doesn't exist
    end unless g == new_resource.group_name # Dealing with managed group later
  end

  group new_resource.group_name do
    gid new_resource.group_id if new_resource.group_id
    members users_groups[new_resource.group_name]
  end
end

private

def manage_home_files?(home_dir, _user)
  # Don't manage home dir if it's NFS mount
  # and manage_nfs_home_dirs is disabled
  if home_dir == '/dev/null'
    false
  elsif fs_remote?(home_dir)
    new_resource.manage_nfs_home_dirs ? true : false
  else
    true
  end
end
