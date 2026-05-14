# users_manage

Manages operating system groups, users, home directories, and SSH key files from an explicit array
of user hashes or data bag search results.

## Actions

| Action    | Description                                |
|-----------|--------------------------------------------|
| `:create` | Creates the group and matching users       |
| `:remove` | Removes matching users marked for removal  |

## Properties

| Property               | Type          | Default   | Description                                      |
|------------------------|---------------|-----------|--------------------------------------------------|
| `group_name`           | String        | name      | Group name to manage                             |
| `group_id`             | Integer       | nil       | Numeric group id                                 |
| `users`                | Array         | `[]`      | User hashes to evaluate for the managed group    |
| `cookbook`             | String        | `'users'` | Cookbook containing SSH key templates            |
| `manage_nfs_home_dirs` | true, false   | `true`    | Manage home files when the home is on NFS        |
| `system`               | true, false   | `false`   | Create the managed group as a system group       |
| `data_bag`             | String        | nil       | Deprecated; pass data bag search results instead |

## Examples

### Create users from an array

```ruby
managed_users = [
  {
    id: 'deploy',
    groups: ['sysadmin'],
    shell: '/bin/bash',
    ssh_keys: ['ssh-ed25519 AAAA... deploy@example'],
  },
]

users_manage 'sysadmin' do
  group_id 2300
  users managed_users
  action :create
end
```

### Create users from a data bag

```ruby
users_manage 'sysadmin' do
  group_id 2300
  users search('users', '*:*')
  action :create
end
```

### Remove users marked for removal

```ruby
users_manage 'retired' do
  users [
    {
      id: 'olduser',
      action: 'remove',
      groups: ['retired'],
      manage_home: true,
      force: true,
    },
  ]
  action :remove
end
```
