# Cookbook Name:: users
# Recipe:: fe

# Searches data bag "users" for groups attribute "fe".
# Places returned users in Unix group "fe" with GID 2304.
users_manage "fe" do
  group_id 2304
  action [ :remove, :create ]
end
