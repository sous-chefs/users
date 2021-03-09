default['users_test']['users'] = []

default['users_test']['users'] += [{
  'id': 'test_user',
  'uid': 9001,
  'comment': 'Test User',
  'password': '$1$5cE1rI/9$4p0fomh9U4kAI23qUlZVv/', # Do not do this in a production environment.
  'shell': '/bin/bash',
  'ssh_keys': '"ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local",',
  'groups': %w(testgroup nfsgroup),
  'manage_home': true,
}]

default['users_test']['users'] += [{
  'username': 'test_user_keys_from_url',
  'password': '$1$5cE1rI/9$4p0fomh9U4kAI23qUlZVv/', # Do not do this in a production environment.
  'uid': 9002,
  'comment': 'Test User who grabs ssh keys from a url',
  'shell': '/bin/bash',
  'ssh_keys': [
    'https://github.com/majormoses.keys',
    'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNQCPO0ZZEa1== chefuser@mylaptop.local',
  ],
  'groups': %w(testgroup nfsgroup),
}]

default['users_test']['users'] += [{
  'username': 'usertoremove',
  'action': 'remove',
  'groups': %w(testgroup),
  'force': true,
  'manage_home': true,
}]

default['users_test']['users'] += [{
  'id': 'bogus_user',
  'action': 'remove',
  'groups': %w(testgroup nfsgroup),
}]

default['users_test']['users'] += [{
  'id': 'user_with_dev_null_home',
  'groups': ['testgroup'],
  'shell': '/usr/bin/bash',
  'home': '/dev/null',
},
{
  'id': 'user_with_nfs_home_first',
  'groups': ['testgroup'],
},
{
  'id': 'user_with_nfs_home_second',
  'groups': ['nfsgroup'],
},
{
  'id': 'user_with_local_home',
  'ssh_keys': ["ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local"],
  'groups': ['testgroup'],
}]
