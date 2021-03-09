user 'usertoremove' do
  manage_home true
  action :nothing
end

users_manage 'testgroup' do
  users_hash node['users_test']['users']
  group_id 3000
  action [:remove, :create]
  notifies :create, 'user[usertoremove]', :before
end

# users_manage 'nfsgroup' do
#   users_hash node['users_test']['users'].to_hash
#   group_id 4000
#   action [:remove, :create]
#   manage_nfs_home_dirs false
# end
