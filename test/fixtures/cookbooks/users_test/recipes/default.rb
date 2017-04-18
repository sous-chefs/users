user 'mwaddams' do
  manage_home true
end

users_manage 'testgroup' do
  group_id 3000
  action [:remove, :create]
  data_bag 'test_home_dir'
end

users_manage 'nfsgroup' do
  group_id 4000
  action [:remove, :create]
  data_bag 'test_home_dir'
  manage_nfs_home_dirs false
end
