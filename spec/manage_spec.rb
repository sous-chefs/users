require 'chefspec'

users = [{
  'id': 'test_user',
  'uid': 9001,
  'comment': 'Test User',
  'password': '$1$5cE1rI/9$4p0fomh9U4kAI23qUlZVv/', # Do not do this in a production environment.
  'shell': '/bin/bash',
  'ssh_keys': 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local',
  'groups': %w(testgroup nfsgroup),
  'manage_home': true,
},
{
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
},
{
  'id': 'usertoremove',
  'action': 'remove',
  'groups': %w(testgroup),
  'force': true,
  'manage_home': true,
},
{
  'id': 'bogus_user',
  'action': 'remove',
  'groups': %w(nfsgroup),
},
{
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

describe 'users_manage' do
  step_into :users_manage
  platform 'ubuntu'

  context 'running with "user_manage testgroup"' do
    recipe do
      users_manage 'testgroup' do
        users users
        group_id 3000
        action [:remove, :create]
      end
    end

    it 'creates groups' do
      is_expected.to create_group('testgroup')
    end

    it 'creates users' do
      is_expected.to create_user('user_with_dev_null_home')
      is_expected.to create_user('user_with_local_home')
      is_expected.to create_user('user_with_nfs_home_first')
    end

    it 'removes users' do
      is_expected.to remove_user('usertoremove')
    end

    it 'not supports managing /dev/null home dir' do
      is_expected.to create_user('user_with_dev_null_home')
        .with(manage_home: false)
    end

    it 'supports managing local home dir' do
      is_expected.to create_user('user_with_local_home')
        .with(manage_home: true)
    end

    it 'not tries to manage .ssh dir for user "user_with_dev_null_home"' do
      is_expected.to_not create_directory('/dev/null')
    end

    it 'manages .ssh dir for local user' do
      is_expected.to create_directory('/home/user_with_local_home/.ssh')
    end

    it 'manages nfs home dir if manage_nfs_home_dirs is set to true' do
      is_expected.to_not create_directory('/home/user_with_nfs_home_first/.ssh')
    end

    it 'does not manage nfs home dir if manage_nfs_home_dirs is set to false' do
      is_expected.to_not create_directory('/home/user_with_nfs_home_second/.ssh')
    end

    it 'manages groups' do
      is_expected.to create_users_manage('testgroup')
    end
  end

  context 'running with "user_manage nfsgroup"' do
    recipe do
      users_manage 'nfsgroup' do
        users users
        group_id 4000
        action [:remove, :create]
      end
    end

    it 'creates groups' do
      is_expected.to create_group('nfsgroup')
    end

    it 'creates users' do
      is_expected.to create_user('user_with_nfs_home_second')
    end

    it 'removes users' do
      is_expected.to remove_user('bogus_user')
    end

    it 'manages nfs home dir if manage_nfs_home_dirs is set to true' do
      is_expected.to_not create_directory('/home/user_with_nfs_home_first/.ssh')
    end

    it 'does not manage nfs home dir if manage_nfs_home_dirs is set to false' do
      is_expected.to_not create_directory('/home/user_with_nfs_home_second/.ssh')
    end

    it 'manages groups' do
      is_expected.to create_users_manage('nfsgroup')
    end
  end
end
