#
# Cookbook Name:: users
# Provider:: manage
#
# Copyright 2011, Eric G. Wolfe
# Copyright 2009-2011, Chef Software, Inc.
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

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

def initialize(*args)
  super
  @action = :create
end

def chef_solo_search_installed?
  klass = Search.const_get('Helper')
  return klass.is_a?(Class)
rescue NameError
  return false
end

action :remove do
  if Chef::Config[:solo] && !chef_solo_search_installed?
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.')
  else
    search(new_resource.data_bag, "groups:#{new_resource.search_group} AND action:remove") do |rm_user|
      user rm_user['username'] ||= rm_user['id'] do
        action :remove
      end
    end
  end
end

action :create do
  security_group = Array.new

  if Chef::Config[:solo] && !chef_solo_search_installed?
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.')
  else
    search(new_resource.data_bag, "groups:#{new_resource.search_group} AND NOT action:remove") do |u|
      u['username'] ||= u['id']

      if node['apache'] && node['apache']['allowed_openids']
        Array(u['openid']).compact.each do |oid|
          node.default['apache']['allowed_openids'] << oid unless node['apache']['allowed_openids'].include?(oid)
        end
      end

      # Set home_basedir based on platform_family
      case node['platform_family']
      when 'mac_os_x'
        home_basedir = '/Users'
      when 'debian', 'rhel', 'fedora', 'arch', 'suse', 'freebsd'
        home_basedir = '/home'
      end

      # Set home to location in data bag,
      # or a reasonable default ($home_basedir/$user).
      if u['home']
        home_dir = u['home']
      else
        home_dir = "#{home_basedir}/#{u['username']}"
      end

      maingroup = Hash.new
      othergroups = Hash.new

      # Look for main group
      u['groups'].each do |groupname, values|
        if values['main']
          values['gid'] && values['gid'].is_a?(Integer) ? maingroup[groupname] = values['gid'] : maingroup[groupname] = nil
        else
          values['gid'] && values['gid'].is_a?(Integer) ? othergroups[groupname] = values['gid'] : othergroups[groupname] = nil
        end
      end

      # If there's no main group defined and there's one group only we assume it's in fact main
      maingroup = othergroups if maingroup.empty? && othergroups.keys.size == 1

      # Skip to next user if groups are not properly set
      if maingroup.empty?
        Chef::Log.warn("Main group not set and yet many groups defined for #{u['username']}, skipping")
        next
      elsif maingroup.keys.size > 1
        Chef::Log.warn("Main group defined more than once for #{u['username']}, skipping")
        next
      end

      group "#{u['username']}_#{maingroup.keys[0]}" do
        gid maingroup.keys.first if maingroup.keys.first
        group_name maingroup.keys[0]
      end

      # If gid wasn't specifically defined we need to find it out now
      if maingroup.keys.first.nil?
        require 'etc'
        maingroup[maingroup.keys[0]] = Etc.getgrnam(maingroup.keys[0])['gid']
      end

      unless othergroups.empty?
        othergroups.each do |groupname, gid|
          group "#{u['username']}_#{groupname}" do
            gid gid if gid
            group_name groupname
          end
        end
      end

      # Add users to security_group only if their groups passed OK
      security_group << u['username']

      # Create user object.
      # Do NOT try to manage null home directories.
      user u['username'] do
        uid u['uid']
        gid maingroup.keys[1]
        shell u['shell']
        comment u['comment']
        password u['password'] if u['password']
        if home_dir == '/dev/null'
          supports manage_home: false
        else
          supports manage_home: true
        end
        home home_dir
        action u['action'] if u['action']
      end

      if manage_home_files?(home_dir)
        Chef::Log.warn("Managing home files for #{u['username']}")

        directory "#{home_dir}/.ssh" do
          owner u['username']
          group maingroup[0]
          mode 0700
        end

        template "#{home_dir}/.ssh/authorized_keys" do
          source 'authorized_keys.erb'
          cookbook new_resource.cookbook
          owner u['username']
          group maingroup[0]
          mode 0600
          variables ssh_keys: u['ssh_keys']
          only_if { u['ssh_keys'] }
        end

        if u['ssh_private_key']
          key_type = u['ssh_private_key'].include?('BEGIN RSA PRIVATE KEY') ? 'rsa' : 'dsa'
          template "#{home_dir}/.ssh/id_#{key_type}" do
            source 'private_key.erb'
            cookbook new_resource.cookbook
            owner u['id']
            group maingroup[0]
            mode 0400
            variables private_key: u['ssh_private_key']
          end
        end

        if u['ssh_public_key']
          key_type = u['ssh_public_key'].include?('ssh-rsa') ? 'rsa' : 'dsa'
          template "#{home_dir}/.ssh/id_#{key_type}.pub" do
            source 'public_key.pub.erb'
            cookbook new_resource.cookbook
            owner u['id']
            group maingroup[0]
            mode 0400
            variables public_key: u['ssh_public_key']
          end
        end
      else
        Chef::Log.warn("Not managing home files for #{u['username']}")
      end
    end
  end

  # Add to group (and create it) only if search returns users belonging to it
  # so that empty groups are not created
  group new_resource.group_name do
    members security_group
    not_if { security_group.nil? || security_group.empty? }
  end
end

private

def manage_home_files?(home_dir)
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
