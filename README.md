Description
===========

Creates users from a databag search.

Requirements
============

Platform
--------

* Debian, Ubuntu
* CentOS, Red Hat, Fedora
* FreeBSD

A data bag populated with user objects must exist. The default data
bag in this recipe is `users`. See USAGE.

Usage
=====

To include just the LWRPs in your cookbook, use:

    include_recipe "users"

Otherwise, this cookbook is specific for setting up `sysadmin` group and users
with the sysadmins recipe for now.

    include_recipe "users::sysadmins"


Use knife to create a data bag for users.

    knife data bag create users

Create a user in the data_bag/users/ directory.

When using an
[Omnibus ruby](http://tickets.opscode.com/browse/CHEF-2848), one can
specify an optional password hash. This will be used as the user's
password.

The hash can be generated with the following command.

    openssl passwd -1 "plaintextpassword"

Note: The ssh_keys attribute below can be either a String or an Array.
However, we are recommending the use of an Array.

    {
      "id": "bofh",
      "ssh_keys": "ssh-rsa AAAAB3Nz...yhCw== bofh",
    }

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
      "comment": "BOFH",
      "nagios": {
        "pager": "8005551212@txt.att.net",
        "email": "bofh@example.com"
      },
      "openid": "bofh.myopenid.com"
    }

Remove a user, johndoe1.

    knife data bag users johndoe1
    {
      "id": "johndoe1",
      "groups": [ "sysadmin", "dba", "devops" ],
      "uid": 2002,
      "action": "remove",
      "comment": "User quit, retired, or fired."
    }

* Note only user bags with the "action : remove" and a search-able
  "group" attribute will be purged by the :remove action.

The sysadmins recipe makes use of the `users_manage` Lightweight
Resource Provider (LWRP), and looks like this:

    users_manage "sysadmin" do
      group_id 2300
      action [ :remove, :create ]
    end

Note this LWRP searches the `users` data bag for the `sysadmin` group
attribute, and adds those users to a Unix security group `sysadmin`.
The only required attribute is group_id, which represents the numeric
Unix gid and *must* be unique. The default action for the LWRP is
`:create` only.

If you have different requirements, for example:

 * You want to search a different data bag specific to a role such as
   mail. You may change the data_bag searched.
   - data_bag `mail`
 * You want to search for a different group attribute named
   `postmaster`. You may change the search_group attribute. This
   attribute defaults to the LWRP resource name.
   - search_group `postmaster`
 * You want to add the users to a security group other than the
   lightweight resource name. You may change the group_name attribute.
   This attribute also defaults to the LWRP resource name.
   - group_name `wheel`

Putting these requirements together our recipe might look like this:

    users_manage "postmaster" do
      data_bag "mail"
      group_name "wheel"
      group_id 10
    end

The latest version of knife supports reading data bags from a file and
automatically looks in a directory called +data_bags+ in the current
directory. The "bag" should be a directory with JSON files of each
item. For the above:

    mkdir data_bags/users
    $EDITOR data_bags/users/bofh.json

Paste the user's public SSH key into the ssh_keys value. Also make
sure the uid is unique, and if you're not using bash, that the shell
is installed. The default search, and Unix group is sysadmin.

The recipe, by default, will also create the sysadmin group. If you're
using the opscode sudo cookbook, they'll have sudo access in the
default site-cookbooks template. They won't have passwords though, so
the sudo cookbook's template needs to be adjusted so the sysadmin
group has NOPASSWD.

The sysadmin group will be created with GID 2300. This may become an
attribute at a later date.

The Apache cookbook can set up authentication using OpenIDs, which is
set up using the openid key here. See the Opscode 'apache2' cookbook
for more information about this.

Chef Solo
---------

As of version 1.4.0, this cookbook might work with Chef Solo when
using
[chef-solo-search by edelight](https://github.com/edelight/chef-solo-search).
That cookbook is not a dependency of this one as Chef solo doesn't
support dependency resolution using cookbook metadata - all cookbooks
must be provided to the node manually when using Chef Solo.

Customizing User Environments
-----------------------------
It is sometimes desirable to allow for the customization of the shell
environment on a per-user basis.  Things like .vimrc or .my.cnf can
make life easier for shell users.

The philosophy here is that all files that customize a user environment will
appear in the users home directory.  The owner and group
of a file will always be the set to the user and their group, but file
permissions are exposed for control to simplify requirements such as those for
the `~/.ssh/authorized_keys` file.

If you want to provide customization for users on a per-user basis, wrap this
cookbook and call the LWRP.  A snippet of a wrapping cookbooks default recipe
might look something like this:

  # Include this recipe so the LWRP is active
  include_recipe 'users::default'

  # Chef creates a standard sudo group akin to the Redhat `wheel` or the Debian
  # `sudo`.
  users_manage 'sysadmin' do
    action [ :remove, :create ]
    custom_env true
    group_id 2300
    wrapper_cookbook 'cook_users'
  end

Note that the `custom_env` attribute must be set to `true` and that the
`wrapper_cookbook` attribute must be set to the name of the cookbook
wrapping the call to the LWRP.  This is necessary so Chef can find the
files associated with the user.

In addition to the JSON example above the `custom_env` key is present at the
top level with a structure as follows:

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
      "comment": "BOFH",
      "nagios": {
        "pager": "8005551212@txt.att.net",
        "email": "bofh@example.com"
      },
      "openid": "bofh.myopenid.com",
      "custom_env": {
        "files": {
          "_inputrc": {
            "mode": "00600",
            "path": ".inputrc"
          },
          "ssh_config": {
            "mode": "00600",
            "path": ".ssh/ssh_config"
          }
        },
        "templates": {
          "_my_cnf.erb": {
            "mode": "00600",
            "path": ".my.cnf"
          }
        }
      }
    }

Note that it is the combination (logical and) of the `custom_env` attribute of
the LWRP and the existence of the `custom_env` key in the JSON that will cause
Chef to look for files.  Thus if some users do not have customizations specified
in the JSON, the Chef run will _not_ fail.

Files specified in the JSON under `custom_env.files` will be looked for
in the wrapper cookbook in the path `files/default/USERNAME` (where
USERNAME is really the id of the bag item).  Similarly templates specified
in the JSON under `custom_env.templates` will be looked for in the wrapper
cookbook path `templates/default/USERNAME`.  So the cookbook file structure
supporting the above JSON would look like this:

    files
    └── default
        └── USERNAME
            ├── _inputrc
            └── ssh_config
    templates
    └── default
        └── USERNAME
            └── _my_cnf.erb

Note that if a file is specified in the JSON but does not exist in the cookbook
an error will halt the Chef run.  Similary a file existing in the file system
but not specified in the JSON will not be laid down by Chef.


License and Author
==================

Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)

Copyright:: 2009-2013, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
