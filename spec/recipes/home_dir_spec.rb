require 'spec_helper'

describe 'users_test::default' do
  let(:stat) { double('stat') }
  let(:stat_nfs) { double('stat_nfs') }

  before do
    allow(stat).to receive(:run_command).and_return(stat)
    allow(stat).to receive(:stdout).and_return('none')

    allow(stat_nfs).to receive(:run_command).and_return(stat_nfs)
    allow(stat_nfs).to receive(:stdout).and_return('nfs')

    allow(Mixlib::ShellOut).to receive(:new).with('stat -f -L -c %T /home/user_with_local_home 2>&1').and_return(stat)
    allow(Mixlib::ShellOut).to receive(:new).with('stat -f -L -c %T /home/user_with_nfs_home_first 2>&1').and_return(stat_nfs)
    allow(Mixlib::ShellOut).to receive(:new).with('stat -f -L -c %T /home/user_with_nfs_home_second 2>&1').and_return(stat_nfs)

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with('/usr/bin/bash').and_return(true)
  end

  cached(:chef_run) do
    ChefSpec::ServerRunner.new(
      step_into: %w(users_manage),
      platform: 'ubuntu',
      version: '16.04'
    ) do |_node, server|
      server.create_data_bag('test_home_dir',
        'user_with_dev_null_home' => {
          id: 'user_with_dev_null_home',
          groups: ['testgroup'],
          shell: '/usr/bin/bash',
          home: '/dev/null',
        },
        'user_with_nfs_home_first' => {
          id: 'user_with_nfs_home_first',
          groups: ['testgroup'],
        },
        'user_with_nfs_home_second' => {
          id: 'user_with_nfs_home_second',
          groups: ['nfsgroup'],
        },
        'user_with_local_home' => {
          id: 'user_with_local_home',
          ssh_keys: ["ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSU\nGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3\nPbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XA\nt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/En\nmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbx\nNrRFi9wrf+M7Q== chefuser@mylaptop.local"],
          groups: ['testgroup'],
        })
    end.converge(described_recipe)
  end

  context 'Resource "users_manage"' do
    it 'creates users' do
      expect(chef_run).to create_user('user_with_dev_null_home')
      expect(chef_run).to create_user('user_with_local_home')
      expect(chef_run).to create_user('user_with_nfs_home_first')
      expect(chef_run).to create_user('user_with_nfs_home_second')
    end

    it 'creates groups' do
      expect(chef_run).to create_group('testgroup')
      expect(chef_run).to create_group('nfsgroup')
    end

    it 'not supports managing /dev/null home dir' do
      expect(chef_run).to create_user('user_with_dev_null_home')
        .with(manage_home: false)
    end

    it 'supports managing local home dir' do
      expect(chef_run).to create_user('user_with_local_home')
        .with(manage_home: true)
    end

    it 'not tries to manage .ssh dir for user "user_with_dev_null_home"' do
      expect(chef_run).to_not create_directory('/dev/null')
    end

    it 'manages .ssh dir for local user' do
      expect(chef_run).to create_directory('/home/user_with_local_home/.ssh')
    end

    it 'manages nfs home dir if manage_nfs_home_dirs is set to true' do
      expect(chef_run).to_not create_directory('/home/user_with_nfs_home_first/.ssh')
    end

    it 'does not manage nfs home dir if manage_nfs_home_dirs is set to false' do
      expect(chef_run).to_not create_directory('/home/user_with_nfs_home_second/.ssh')
    end

    it 'manages groups' do
      expect(chef_run).to create_users_manage('testgroup')
      expect(chef_run).to create_users_manage('nfsgroup')
    end
  end
end
