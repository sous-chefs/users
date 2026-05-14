# Migration Guide

## Full Custom Resource Migration

The `users` cookbook now exposes `users_manage` as the public API. The legacy root recipes have
been removed:

* `recipe[users::default]`
* `recipe[users::sysadmins]`

Both recipes previously emitted deprecation warnings and did not perform account management.
Wrapper cookbooks should call `users_manage` directly from their own recipes.

## Before

```ruby
include_recipe 'users::sysadmins'
```

## After

```ruby
sysadmin_users = search('users', '*:*')

users_manage 'sysadmin' do
  group_id 2300
  users sysadmin_users
  action :create
end
```

## Test Cookbook Examples

The integration examples now live in `test/cookbooks/test/recipes/default.rb`. They demonstrate
direct `users_manage` usage with data bag search results and explicit user arrays.
