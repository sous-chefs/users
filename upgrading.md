# Upgrading from v5.7.0 or earlier

From v6.0.0 of the users cookbook we have removed the hard dependency on data bags. This means that you can no longer pass the data bag name to the users_manage resource.

The resource now expects an Array of Hashes for all the users and can as such be used with other sources then data bags.

You can still use data bags as detailed below.

## Major Changes

Data bags are no longer directly supported. Before v6.0.0 you would do the following:

```ruby
users_manage 'GROUPNAME' do
  group_id GROUPID
  action [:create]
  data_bag 'DATABAG_NAME'
end
```

In the example above you are passing the name of the data bag to the resource. This is no longer supported.

You now need to pass the content of the data bag to the resource like this:

```ruby
# Get the users from the data bag
users_from_databag = search('DATABAG_NAME', '*:*')

# Pass the content of users_from_databag as the users property
users_manage 'GROUPNAME' do
  group_id GROUPID
  action [:create]
  users users_from_databag
end
```