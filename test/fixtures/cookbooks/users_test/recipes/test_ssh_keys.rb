users_manage 'groupone' do
  group_id 1000
  action [:remove, :create]
  data_bag 'test_ssh_keys'
end

users_manage 'grouptwo' do
  group_id 2000
  action [:remove, :create]
  data_bag 'test_ssh_keys'
end

users_manage 'sharedgroup' do
  group_id 3000
  action [:remove, :create]
  data_bag 'test_ssh_keys'
end
