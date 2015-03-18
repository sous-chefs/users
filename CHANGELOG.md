users Cookbook CHANGELOG
========================
This file is used to list changes made in each version of the users cookbook.

v1.8.2 (2015-03-18)
-------------------
- No changes, just republishing 1.8.1

v1.8.1 (2015-03-12)
-------------------
- Add `source_url` and `issues_url` to the metadata.rb so Supermarket can display 
appropriate links

v1.8.0 (2015-03-09)
-------------------
- Expose LWRP state attributes
- [COOK-4401] - Add unit tests with ChefSpec
- [COOK-4404] - Determine file system and add manage_nfs_home_dirs attribute to disable 
managing NFS mounted home directories
- Remove `converge_by` when creating home directory, the directory resource 
already handles this
- Do not manage home directory if the path does not exist
- Add integration with TravisCI
- "Opscode" to "Chef" replacements
- Retire unsupported Ruby 1.9.3 and add Ruby 2.2 to the Travis integration tests
- Updates for RSpec 3

v1.7.0 (2014-02-14)
-------------------
- [COOK-4139] - users_manage resource always notifies
- [COOK-4078] - users cookbook fails in why-run mode for .ssh directory
- [COOK-3959] - Add support for Mac OS X to users cookbook


v1.6.0
------
### Bug
- **[COOK-3744](https://tickets.opscode.com/browse/COOK-3744)** - Allow passing an action option via the `data_bag` to the user resource


v1.5.2
------
### Bug
- **[COOK-3215](https://tickets.opscode.com/browse/COOK-3215)** - Make `group_id` optional

v1.5.0
------
- [COOK-2427] - Mistakenly released instead of sudo :-).

v1.4.0
------
- [COOK-2479] - Permit users cookbook to work with chef-solo if edelight/chef-solo-search is installed
- [COOK-2486] - specify precedence when setting node attribute

v1.3.0
------
- [COOK-1842] - allow specifying private SSH keys
- [COOK-2021] - Empty default recipe for including users LWRPs

v1.2.0
------
- [COOK-1398] - Provider manage.rb ignores username attribute
- [COOK-1582] - ssh_keys should take an array in addition to a string separated by new lines

v1.1.4
------
- [COOK-1396] - removed users get recreated
- [COOK-1433] - resolve foodcritic warnings
- [COOK-1583] - set passwords for users

v1.1.2
------
- [COOK-1076] - authorized_keys template not found in another cookbook

v1.1.0
------
- [COOK-623] - LWRP conversion
