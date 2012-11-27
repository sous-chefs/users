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

def initialize(*args)
    super
    @action = :create
end

action :remove do
    if Chef::Config[:solo]
	Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    else
	search(new_resource.data_bag, "groups:#{new_resource.search_group} AND action:remove") do |rm_user|
	    user rm_user['id'] do
		action :remove
	    end
	end
	new_resource.updated_by_last_action(true)
    end
end

action :create do
    security_group = Array.new

    if Chef::Config[:solo]
	Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
    else
	search(new_resource.data_bag, "groups:#{new_resource.search_group} NOT action:remove") do |u|
	    # add the current user to the unix group we're going to create
	    security_group << u['id']

	    # if no gid was provided create a group based on the u['uid']
	    # if neither were provided then don't specify ids
	    if u[:gid] || u[:uid]
		primary_group = Integer(u[:gid] || u[:uid])

		group u[:id] do
		    action :create
		    gid primary_group
		end
	    else
		group u[:id] do
		    action :create
		end
	    end

	    # The home directory we're going to create is u['home'] or /home/#{u['home']
	    create_home = u[:home] || "/home/#{u[:id]}"

	    # if u['chroot'] exists then the password_home is it, otherwise it's the same as create_home
	    password_home = u[:chroot] || create_home

	    user u[:id] do
		# Set the uid if provided
		if u[:uid]
		    uid u[:uid]
		end

		gid u[:id]

		# u['home'] is defaulted to /home/u['id'] if not present
		home password_home
		# we create the home directory manually
		supports :manage_home => false

		shell u[:shell] || '/usr/sbin/nologin'

		comment u[:comment] || ''

		if u.include? :password
		    password u[:password]
		end
	    end

	    # create the home directory (and chroot) for the user
	    if u[:chroot]
		directory create_home do
		    mode 0755
		    owner 'root'
		    group 'root'
		end

		directory "#{create_home}#{password_home}" do
		    mode 0755
		    owner u[:id]
		    group u[:id]
		end
	    else
		directory create_home do
		    mode 0755
		    owner u[:id]
		    group u[:id]
		end
	    end

	    # create the .ssh/authorized_keys if ssh_keys are provided
	    if u[:ssh_keys]
		directory "#{create_home}/.ssh" do
		    mode 0700
		    owner u[:id]
		    group u[:id]
		end

		template "#{create_home}/.ssh/authorized_keys" do
		    source "authorized_keys.erb"
		    cookbook new_resource.cookbook
		    owner u[:id]
		    group u[:id]
		    mode "0600"
		    variables :ssh_keys => u['ssh_keys']
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
