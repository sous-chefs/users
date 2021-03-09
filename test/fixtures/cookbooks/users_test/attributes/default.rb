default['users_test']['users']['test_user'] = {
  'id': 'test_user',
  'uid': 9001,
  'comment': 'Test User',
  'password': '$1$5cE1rI/9$4p0fomh9U4kAI23qUlZVv/', # Do not do this in a production environment.
  'shell': '/bin/bash',
  'ssh_keys': '"ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local",',
  'groups': %w(testgroup nfsgroup),
  'manage_home': true,
}

default['users_test']['users']['test_user_keys_from_url'] = {
  'id': 'test_user_keys_from_url',
  'password': '$1$5cE1rI/9$4p0fomh9U4kAI23qUlZVv/', # Do not do this in a production environment.
  'uid': 9002,
  'comment': 'Test User who grabs ssh keys from a url',
  'shell': '/bin/bash',
  'ssh_keys': [
    'https://github.com/majormoses.keys',
    'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNQCPO0ZZEa1== chefuser@mylaptop.local',
  ],
  'groups': %w(testgroup nfsgroup),
}

default['users_test']['users']['usertoremove'] = {
  'id': 'usertoremove',
  'action': 'remove',
  'groups': %w(testgroup),
  'force': true,
  'manage_home': true,
}

default['users_test']['users']['bogus_user'] = {
  'id': 'bogus_user',
  'action': 'remove',
  'groups': %w(testgroup nfsgroup),
}