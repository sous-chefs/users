#
# Cookbook Name:: users
# Provider:: manage
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

def whyrun_supported?
  true
end

def initialize(*args)
  super
  @action = :create
end

def chef_solo_search_installed?
  klass = ::Search::const_get('Helper')
  return klass.is_a?(Class)
rescue NameError
  return false
end

action :remove do
  if Chef::Config[:solo] and not chef_solo_search_installed?
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.")
  else
    search(new_resource.data_bag, "groups:#{new_resource.search_group} AND action:remove") do |rm_user|
      user rm_user['username'] ||= rm_user['id'] do
        action :remove
      end
    end
    new_resource.updated_by_last_action(true)
  end
end

action :create do
  security_group = Array.new

  if Chef::Config[:solo] and not chef_solo_search_installed?
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search unless you install the chef-solo-search cookbook.")
  else
    search(new_resource.data_bag, "groups:#{new_resource.search_group} AND NOT action:remove") do |u|
      u['username'] ||= u['id']
      security_group << u['username']

      if node['apache'] and node['apache']['allowed_openids']
        Array(u['openid']).compact.each do |oid|
          node.default['apache']['allowed_openids'] << oid unless node['apache']['allowed_openids'].include?(oid)
        end
      end

      # Set home to location in data bag,
      # or a reasonable default (/home/$user).
      if u['home']
        home_dir = u['home']
      else
        home_dir = "/home/#{u['username']}"
      end

      # The user block will fail if the group does not yet exist.
      # See the -g option limitations in man 8 useradd for an explanation.
      # This should correct that without breaking functionality.
      if u['gid'] and u['gid'].kind_of?(Numeric)
        group u['username'] do
          gid u['gid']
        end
      end

      # Create user object.
      # Do NOT try to manage null home directories.
      user u['username'] do
        uid u['uid']
        if u['gid']
          gid u['gid']
        end
        shell u['shell']
        comment u['comment']
        password u['password'] if u['password']
        if home_dir == "/dev/null"
          supports :manage_home => false
        else
          supports :manage_home => true
        end
        home home_dir
      end

      if home_dir != "/dev/null"
        directory "#{home_dir}/.ssh" do
          owner u['username']
          group u['gid'] || u['username']
          mode "0700"
        end

        if u['ssh_keys']
          template "#{home_dir}/.ssh/authorized_keys" do
            source "authorized_keys.erb"
            cookbook new_resource.cookbook
            owner u['username']
            group u['gid'] || u['username']
            mode "0600"
            variables :ssh_keys => u['ssh_keys']
          end
        end

        if u['ssh_private_key']
          key_type = u['ssh_private_key'].include?("BEGIN RSA PRIVATE KEY") ? "rsa" : "dsa"
          template "#{home_dir}/.ssh/id_#{key_type}" do
            source "private_key.erb"
            cookbook new_resource.cookbook
            owner u['id']
            group u['gid'] || u['id']
            mode "0400"
            variables :private_key => u['ssh_private_key']
          end
        end

        if u['ssh_public_key']
          key_type = u['ssh_public_key'].include?("ssh-rsa") ? "rsa" : "dsa"
          template "#{home_dir}/.ssh/id_#{key_type}.pub" do
            source "public_key.pub.erb"
            cookbook new_resource.cookbook
            owner u['id']
            group u['gid'] || u['id']
            mode "0400"
            variables :public_key => u['ssh_public_key']
          end
        end

        # If the data bag contains a custom_env and the custom_env input is true
        # layout files as specified.
        if new_resource.custom_env and u['custom_env']

          # We will likely need to create parent directories for things like
          # .byobu and .ssh so Pathname is handy
          require 'pathname'

          # if there are files specified in the data bag then place them
          # per the value associated with the filename.
          if u['custom_env']['files']
            u['custom_env']['files'].each do |file,info|

              parent_path = Pathname.new(info['path']).parent.to_s

              # If the directory does not exist, create it in the users home
              # directory
              unless parent_path == '.'
                directory "#{home_dir}/#{parent_path}" do
                  group u['username']
                  mode '00755'
                  owner u['username']
                  recursive true
                end
              end

              cookbook_file "#{home_dir}/#{info['path']}" do
                cookbook new_resource.wrapper_cookbook
                group u['username']
                mode info['mode']
                owner u['username']
                source "#{u['username']}/#{file}"
              end
            end
          end

          # if there are templates specified in the data bag then place them
          # per the value associated with the filename.
          if u['custom_env']['templates']
            u['custom_env']['templates'].each do |file,info|

              parent_path = Pathname.new(info['path']).parent.to_s

              # If the directory does not exist, create it in the users home
              # directory
              unless parent_path == '.'
                directory "#{home_dir}/#{parent_path}" do
                  group u['username']
                  mode '00755'
                  owner u['username']
                  recursive true
                end
              end

              template "#{home_dir}/#{info['path']}" do
                cookbook new_resource.wrapper_cookbook
                group u['username']
                mode info['mode']
                owner u['username']
                source "#{u['username']}/#{file}"
              end
            end
          end
        end
      end
    end
  end

  group new_resource.group_name do
    gid new_resource.group_id
    members security_group
  end
  new_resource.updated_by_last_action(true)
end
