require 'spec_helper'

describe 'users_test::test_home_dir' do
  let(:stat) { double('stat') }
  let(:stat_nfs) { double('stat_nfs') }

  before do
    ChefSpec::Server.create_data_bag('test_home_dir', {
      user_with_dev_null_home: {
        id: 'user_with_dev_null_home',
        groups: ['testgroup'],
        home: '/dev/null',
      },
      user_with_nfs_home_first: {
        id: 'user_with_nfs_home_first',
        groups: ['testgroup'],
      },
      user_with_nfs_home_second: {
        id: 'user_with_nfs_home_second',
        groups: ['nfsgroup'],
      },
      user_with_local_home: {
        id: 'user_with_local_home',
        groups: ['testgroup'],
      },
    })

    stat.stub(:run_command).and_return(stat)
    stat.stub(:stdout).and_return('none')

    stat_nfs.stub(:run_command).and_return(stat_nfs)
    stat_nfs.stub(:stdout).and_return('nfs')

    Mixlib::ShellOut.stub(:new).with('stat -f -L -c %T /home/user_with_local_home 2>&1').and_return(stat)
    Mixlib::ShellOut.stub(:new).with('stat -f -L -c %T /home/user_with_nfs_home_first 2>&1').and_return(stat_nfs)
    Mixlib::ShellOut.stub(:new).with('stat -f -L -c %T /home/user_with_nfs_home_second 2>&1').and_return(stat_nfs)
  end


  cached(:chef_run) do
    ChefSpec::Runner.new(
      step_into: ['users_manage'],
      platform: 'ubuntu',
      version: '12.04'
    ).converge(described_recipe)
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

    it "not supports managing /dev/null home dir" do
      expect(chef_run).to create_user('user_with_dev_null_home')
        .with_supports(manage_home: false)
    end

    it "supports managing local home dir" do
      expect(chef_run).to create_user('user_with_local_home')
        .with_supports(manage_home: true)
    end

    it 'not tries to manage .ssh dir for user "user_with_dev_null_home"' do
      expect(chef_run).to_not create_directory('/dev/null')
    end

    it 'manages .ssh dir for local user' do
      expect(chef_run).to create_directory('/home/user_with_local_home/.ssh')
    end

    it 'manages nfs home dir if manage_nfs_home_dirs is set to true' do
      expect(chef_run).to create_directory('/home/user_with_nfs_home_first/.ssh')
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
