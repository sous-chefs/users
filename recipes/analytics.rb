# Cookbook Name:: users
# Recipe:: analytics

# Searches data bag "users" for groups attribute "analytics".
# Places returned users in Unix group "analytics" with GID 2302.
users_manage "analytics" do
  group_id 2302
  action [ :remove, :create ]
end
