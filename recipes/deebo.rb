# Cookbook Name:: users
# Recipe:: deebo

# Searches data bag "users" for groups attribute "deebo".
# Places returned users in Unix group "deebo" with GID 2302.
users_manage "deebo" do
  group_id 2303
  action [ :remove, :create ]
end
