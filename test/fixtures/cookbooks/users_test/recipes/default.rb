user 'databag_mwaddams' do
  manage_home true
  action :nothing
end

# Get the users from the data bag
users = search('test_home_dir', '*:*')

# Create the users from the data bag.
users_manage 'testgroup' do
  users users
  group_id 3000
  action [:remove, :create]
  notifies :create, 'user[databag_mwaddams]', :before
end

# Create the users from an attribute
users_manage 'nfsgroup' do
  users node['users_test']['users']
  group_id 4000
  action [:remove, :create]
  manage_nfs_home_dirs false
end

# Creates a group without users.
users_manage 'emptygroup' do
  group_id 5000
  action [:remove, :create]
end

users_manage 'explicituser' do
  users node['users_test']['users']
end

users_manage 'spawns_next_group' do
  users node['users_test']['users']
end

users_manage 'user_before_group' do
  group_id 6000
  users node['users_test']['users']
end
