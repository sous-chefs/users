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

# Creates a group where a user's name matches the group's name
singleuser = [{ username: 'singleuser', groups: ['singleuser'] }]
users_manage 'singleuser' do
  users singleuser
end
