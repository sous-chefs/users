# frozen_string_literal: true

user 'databag_mwaddams' do
  manage_home true
  action :nothing
end

users = search('test_home_dir', '*:*')

users_manage 'testgroup' do
  users users
  group_id 3000
  action [:remove, :create]
  notifies :create, 'user[databag_mwaddams]', :before
end

users_manage 'nfsgroup' do
  users node['test']['users']
  group_id 4000
  action [:remove, :create]
  manage_nfs_home_dirs false
end

users_manage 'emptygroup' do
  group_id 5000
  action [:remove, :create]
end

users_manage 'explicituser' do
  users node['test']['users']
end

users_manage 'spawns_next_group' do
  users node['test']['users']
end

users_manage 'user_before_group' do
  group_id 6000
  users node['test']['users']
end

users_manage 'nonstandard_homedir_perms' do
  users node['test']['users']
end

users_manage 'system_group' do
  users node['test']['users']
  system true
end
