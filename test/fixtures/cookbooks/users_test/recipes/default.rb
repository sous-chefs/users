user 'bogus_user' do
  manage_home true
  action :nothing
end

users_manage 'testgroup' do
  users node['users_test']['users']
  group_id 3000
  action [:remove, :create]
  notifies :create, 'user[bogus_user]', :before
end

users_manage 'nfsgroup' do
  users node['users_test']['users']
  group_id 4000
  action [:remove, :create]
  manage_nfs_home_dirs false
end
