# users Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/users.svg)](https://supermarket.chef.io/cookbooks/users)
[![CI State](https://github.com/sous-chefs/users/workflows/ci/badge.svg)](https://github.com/sous-chefs/users/actions?query=workflow%3Aci)
[![OpenCollective](https://opencollective.com/sous-chefs/backers/badge.svg)](#backers)
[![OpenCollective](https://opencollective.com/sous-chefs/sponsors/badge.svg)](#sponsors)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)

Manages OS users and groups (optionally from databags).

## Scope

This cookbook is concerned with the management of OS users and groups (optionally from databags). It also manages the distribution of ssh keys to a user's home directory.

## Maintainers

This cookbook is maintained by the Sous Chefs. The Sous Chefs are a community of Chef cookbook maintainers working together to maintain important cookbooks. If you’d like to know more please visit [sous-chefs.org](https://sous-chefs.org/) or come chat with us on the Chef Community Slack in [#sous-chefs](https://chefcommunity.slack.com/messages/C2V7B88SF).

## Requirements

If you are upgrading from a version < 6.0.0 please see [upgrading.md](https://github.com/sous-chefs/users/upgrading.md)

### Platforms

The following platforms have been tested with Test Kitchen:

- Debian / Ubuntu derivatives
- RHEL and derivatives
- Fedora
- openSUSE / SUSE Linux Enterprises
- FreeBSD / OpenBSD
- macOS
- AIX

### Chef

- Chef 12.7+

### Cookbooks

- none

## Usage

To use the resource `users_manage`, make sure to add the dependency on the users cookbook by the following line to your wrapper cookbook's [metadata.rb](https://docs.chef.io/config_rb_metadata.html):

```
depends 'users'
```

or to pin to a specific version of the users cookbook, in this case any version of 6.X:

```
depends 'users', '~> 6'
```

Then in a recipe use the `user_manage` resource to add all users in the defined group to the system:

```ruby
users_variable = [{
  id: 'databag_test_user',
  ssh_keys: "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local",
  groups: [ 'GROUPNAME' ],
}]

users_manage 'GROUPNAME' do
  group_id GROUPID
  action [:create]
  users users_variable
end
```

Example:

```ruby
users_manage 'testgroup' do
  group_id 3000
  action [:create]
  users node['users']['array_of_users']
end
```

**Note**: The users property needs to be given an Array of Hashes that contains one user per hash. This can be done by passing a data bag like the example below or from any other source.

### Databag Definition

This is an alternative to the attribute definition as mentioned below.

You could for instance create a databag called `users`. You then create a subdatabag for each user object.

A sample user object in a users databag would look like:

```json
{
  "id": "test_user",
  "password": "$1$5cE1rI/9$4p0fomh9U4kAI23qUlZVv/",
  "ssh_keys": [
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local",
    "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNQCPO0ZZEa1== chefuser@mylaptop.local"
  ],
  "groups": [ "testgroup", "nfsgroup" ],
  "uid": 9001,
  "shell": "\/bin\/bash",
  "comment": "Test User"
}
```

A sample user to remove from a system would like like:

```json
{
  "id": "mwaddams",
  "action": "remove",
  "groups": [ "testgroup", "nfsgroup" ]
}
```

### Attributes Definition

This is an alternative to the data bag definition as mentioned above.

Consider having a cookbook called `usermanagement` where you include this `users` cookbook.

You could then set the attributes like this:

```ruby
default['usermanagement']['users'] = [
  {
    id: 'test_user',
    password: '$1$5cE1rI/9$4p0fomh9U4kAI23qUlZVv/',
    ssh_keys: [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local",
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNQCPO0ZZEa1== chefuser@mylaptop.local"
    ],
    groups: %w(testgroup nfsgroup),
    uid: 9001,
    shell: '/bin/bash',
    comment: 'Test User'
  },
  {
     id: 'mwaddams',
     action: 'remove',
     groups: %w(testgroup nfsgroup)
  }
]
```

## User Key Definitions

- `id`: _String_ specifies the username, as well as the data bag object id.
- `password`: _String_ specifies the user's password.
- `ssh_keys`: _Array_ an array of authorized keys that will be managed by Chef to the user's home directory in `$HOME/.ssh/authorized_keys`. A key can include an `https` endpoint that returns a line separated list of keys such as `https://github.com/$GITHUB_USERNAME.keys` this will retrieve all the keys and add it to the array and can be used with static keys as well as dynamic ones.
- `groups`: _Array_ an array of groups that the user will be added to
- `uid`: _Integer_ a unique identifier for the user
- `shell`: _String_ the user's shell
- `comment`:_String_ the [GECOS field](https://en.wikipedia.org/wiki/Gecos_field), generally the User's full name.

Other potential fields (optional):

- `home`: _String_ User's home directory. If not assigned, will be set based on platform and username.
- `manage_home`: _True, False_ Creates/removes the home directory. Defaults to false.
- `homedir_mode`: _String, Integer_ Modifies a user's home directory permissions.
- `no_user_group`: _True, False_ Specifies if the user needs to get a group with the name of the users. Defaults to false.
- `action`: _String_ Supported actions are one's supported by the [user](https://docs.chef.io/resource_user.html#actions) resource. If not specified, the default action is `create`.
- `ssh_private_key`: _String_ manages user's private key generally ~/.ssh/id_*
- `ssh_public_key`: _String_ manages user's public key generally ~/.ssh/id_*.pub
- `authorized_keys_file`: _String_ a nonstandard location for the authorized_keys file
- `gid`: _String, Integer_ Specifies the primary group of a user by the gid number or the group name. If `gid` is an integer and no `primary_group` is specified than the gid will be assigned to the username group, if applicable. The group will be created if it doesn't exist.
- `primary_group`: _String_ To be used in combination with the `gid` field when the `gid` is an integer. Specifying the group name prevents errors where the user is created before their primary group.
- `system`: _True, False_ Specifies if a user is a system account. See the `-r` option of `useradd`.

## Resources Overview

### users_manage

The `users_manage` resource manages users and groups based off the `users` property or of a data bag search and the specified action(s).

#### Examples

Creates the `sysadmin` group and users defined in the `users` databag.

```ruby
# Get the users from the data bag
users_from_databag = search('users', '*:*')

users_manage 'sysadmin' do
  group_id 2300
  action [:create]
  users users_from_databag
end
```

Creates the `testgroup` group, and users defined in the `test_home_dir` attribute.

```ruby
users_manage 'testgroup' do
  group_id 3000
  action [:create]
  users node['test_home_dir']
end
```

Creates the `nfsgroup` group, and users defined in the `test_home_dir` local variable and does not manage nfs home directories.

```ruby
users_manage 'nfsgroup' do
  group_id 4000
  action [:create]
  users test_home_dir
  manage_nfs_home_dirs false
end
```

#### Parameters

- `users` _Array_ This is the source of the users. It needs to be an array of hashes, where each hash represents its own user. You can use data bags, attributes or something different here.
- `group_name` _String_ name of the group to create, defaults to resource name
- `group_id` _Integer_ numeric id of the group to create, default is to allow the OS to pick next
- `cookbook` _String_ name of the cookbook that the authorized_keys template should be found in
- `manage_nfs_home_dirs` _Boolean_ whether to manage nfs home directories.
- `system` _True, False_ Specifies if a group is a system group. See the `-r` option of `groupadd`.

## Recipe Overview

Recipes are not directly used. Please include the `users_manage` resource directly in your cookbook.

## Data bag Overview

**Reminder** You do not have to use data bags, you can also pass the users directly to the resource from a different source as explained above.

**Reminder** Data bags generally should not be stored in cookbooks, but in a policy repo within your organization. Data bags are useful across cookbooks, not just for a single cookbook.

Use knife to create a data bag for users.

```bash
knife data bag create users
```

Create a user in the data_bag/users/ directory.

An optional password hash can be specified that will be used as the user's password.

The hash can be generated with the following command.

```bash
openssl passwd -1 "plaintextpassword"
```

Note: The ssh_keys attribute below can be either a String or an Array. However, we are recommending the use of an Array.

```json
{
  "id": "bofh",
  "ssh_keys": "ssh-rsa AAAAB3Nz...yhCw== bofh"
}
```

```json
{
  "id": "bofh",
  "password": "$1$d...HgH0",
  "ssh_keys": [
    "ssh-rsa AAA123...xyz== foo",
    "ssh-rsa AAA456...uvw== bar"
  ],
  "groups": [ "sysadmin", "dba", "devops" ],
  "uid": 2001,
  "shell": "\/bin\/bash",
  "comment": "BOFH"
}
```

You can pass any action listed in the [user](http://docs.chef.io/chef/resources.html#user) resource for Chef via the "action" option. For Example:

Lock a user, johndoe1.

```bash
knife data bag edit users johndoe1
```

And then change the action to "lock":

```javascript
{
  "id": "johndoe1",
  "groups": ["sysadmin", "dba", "devops"],
  "uid": 2002,
  "action": "lock", // <--
  "comment": "User violated access policy"
}
```

Remove a user, johndoe1.

```bash
knife data bag edit users johndoe1
```

And then change the action to "remove":

```javascript
{
  "id": "johndoe1",
  "groups": [ "sysadmin", "dba", "devops" ],
  "uid": 2002,
  "action": "remove", // <--
  "comment": "User quit, retired, or fired."
}
```

- Note only user bags with the "action : remove" and a search-able "group" attribute will be purged by the :remove action.
- As of v2.0.3 you can use the force parameter within the user data bag object for users with action remove. As per [user docs](https://docs.chef.io/resource_user.html) this may leave the system in an inconsistent state. For example, a user account will be removed even if the user is logged in. A user's home directory will be removed, even if that directory is shared by multiple users.

If you have different requirements, for example:

- You want to search a different data bag specific to a role such as mail. You may change the `data_bag` searched.

  ```ruby
  data_bag `mail`
  ```

- You want to search for a different group attribute named `postmaster`. You may change the `search_group` attribute. This attribute defaults to the resource name.

  ```ruby
  search_group `postmaster`
  ```

- You want to add the users to a security group other than the lightweight resource name. You may change the `group_name` attribute. This attribute also defaults to the resource name.

  ```ruby
  group_name `wheel`
  ```

Putting these requirements together our recipe might look like this:

```ruby
users_manage "postmaster" do
  data_bag "mail"
  group_name "wheel"
  group_id 10
end
```

Knife supports reading data bags from a file and automatically looks in a directory called +data_bags+ in the current directory. The "bag" should be a directory with JSON files of each item. For the above:

```bash
$ mkdir data_bags/users
$EDITOR data_bags/users/bofh.json
```

Paste the user's public SSH key into the ssh_keys value. Also make sure the uid is unique, and if you're not using bash, that the shell is installed.

The Apache cookbook can set up authentication using OpenIDs, which is set up using the openid key here. See the Chef Software 'apache2' cookbook for more information about this.

## Contributors

This project exists thanks to all the people who [contribute.](https://opencollective.com/sous-chefs/contributors.svg?width=890&button=false)

### Backers

Thank you to all our backers!

![https://opencollective.com/sous-chefs#backers](https://opencollective.com/sous-chefs/backers.svg?width=600&avatarHeight=40)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website.

![https://opencollective.com/sous-chefs/sponsor/0/website](https://opencollective.com/sous-chefs/sponsor/0/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/1/website](https://opencollective.com/sous-chefs/sponsor/1/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/2/website](https://opencollective.com/sous-chefs/sponsor/2/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/3/website](https://opencollective.com/sous-chefs/sponsor/3/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/4/website](https://opencollective.com/sous-chefs/sponsor/4/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/5/website](https://opencollective.com/sous-chefs/sponsor/5/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/6/website](https://opencollective.com/sous-chefs/sponsor/6/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/7/website](https://opencollective.com/sous-chefs/sponsor/7/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/8/website](https://opencollective.com/sous-chefs/sponsor/8/avatar.svg?avatarHeight=100)
![https://opencollective.com/sous-chefs/sponsor/9/website](https://opencollective.com/sous-chefs/sponsor/9/avatar.svg?avatarHeight=100)
