#
# Cookbook Name:: users
# Recipe:: augment
# Author:: Rafe Colton
#

augment_keys = if data_bag('users').include?('augment_keys')
  data_bag_item('users', 'augment_keys')
end

augment_request_data = node['users_augment']

augmentation_info = if augment_keys && augment_request_data
  augment_request_data.each_with_object([]) do |data, arr|
    username = data[0]
    allowed_users = data[1]['users']

    keys = allowed_users.map do |allowed_user|
      augment_keys[allowed_user]
    end.reject(&:nil?).join("\n")

    arr << {
      authorized_keys_path: data[1]['authorized_keys_path'] || "/home/#{username}/.ssh/authorized_keys",
      keys: keys,
    }
  end
end

bash 'do_augment' do
  code '/root/augment-users'
  user 'root'
  group 'root'
  action :nothing
end

template '/root/augment-users' do
  cookbook 'users'
  source 'augment-users.erb'
  mode 0500
  variables(
    augmentations: augmentation_info,
    verification_string: '# Successfully augmented by Chef recipe[users::augment]'
  )
  notifies :run, 'bash[do_augment]', :delayed
  action [:create, :touch]

  not_if { augmention_info.nil? }
end
