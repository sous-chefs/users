default['users_test']['users'] = [{
  'username': 'usertoremove',
  'action': 'remove',
  'groups': %w(nfsgroup),
  'force': true,
  'manage_home': true,
},
{
  'id': 'databag_mwaddams',
  'action': 'remove',
  'groups': %w(testgroup nfsgroup),
  'manage_home': true,
},
{
  'id': 'user_with_dev_null_home',
  'uid': 5000,
  'groups': ['nfsgroup'],
  'shell': '/bin/bash',
  'home': '/dev/null',
},
{
  'id': 'user_with_nfs_home_first',
  'groups': ['nfsgroup'],
  'shell': '/bin/sh',
},
{
  'id': 'user_with_nfs_home_second',
  'groups': ['nfsgroup'],
},
{
  'id': 'user_with_local_home',
  'groups': ['nfsgroup'],
}]
