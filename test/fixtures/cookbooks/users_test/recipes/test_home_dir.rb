users_manage 'testgroup' do
  group_id 1000
  action [:remove, :create]
  data_bag 'test_home_dir'
end
