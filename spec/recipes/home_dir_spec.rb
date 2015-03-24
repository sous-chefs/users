require 'chef-vault'
require 'spec_helper'

describe 'users_test::test_home_dir' do
  let(:stat) { double('stat') }
  let(:stat_nfs) { double('stat_nfs') }
  let(:user_with_dev_null_home) { { 'id' => 'user_with_dev_null_home', 'groups' => ['testgroup'], 'home' => '/dev/null' } }
  let(:user_with_nfs_home_first) { { 'id' => 'user_with_nfs_home_first', 'groups' => ['testgroup'] } }
  let(:user_with_nfs_home_second) { { 'id' => 'user_with_nfs_home_second', 'groups' => ['nfsgroup'] } }
  let(:user_with_local_home) { { 'id' => 'user_with_local_home', 'groups' => ['testgroup'] } }

  let(:user_with_dev_null_home_item) { 'user_with_dev_null_home' }
  let(:user_with_nfs_home_first_item) { 'user_with_nfs_home_first' }
  let(:user_with_nfs_home_second_item) { 'user_with_nfs_home_second' }
  let(:user_with_local_home_item) { 'user_with_local_home' }

  let(:data_bag_items) {
    [
      user_with_dev_null_home_item,
      user_with_nfs_home_first_item,
      user_with_nfs_home_second_item,
      user_with_local_home_item
    ]
  }

  before do
    allow(stat).to receive(:run_command).and_return(stat)
    allow(stat).to receive(:stdout).and_return('none')

    allow(stat_nfs).to receive(:run_command).and_return(stat_nfs)
    allow(stat_nfs).to receive(:stdout).and_return('nfs')

    allow(Mixlib::ShellOut).to receive(:new).with('stat -f -L -c %T /home/user_with_local_home 2>&1').and_return(stat)
    allow(Mixlib::ShellOut).to receive(:new).with('stat -f -L -c %T /home/user_with_nfs_home_first 2>&1').and_return(stat_nfs)
    allow(Mixlib::ShellOut).to receive(:new).with('stat -f -L -c %T /home/user_with_nfs_home_second 2>&1').and_return(stat_nfs)

    stub_data_bag('test_home_dir').and_return(data_bag_items)
    allow(ChefVault::Item).to receive(:load).with('test_home_dir', user_with_dev_null_home_item).and_return(user_with_dev_null_home)
    allow(ChefVault::Item).to receive(:load).with('test_home_dir', user_with_nfs_home_first_item).and_return(user_with_nfs_home_first)
    allow(ChefVault::Item).to receive(:load).with('test_home_dir', user_with_nfs_home_second_item).and_return(user_with_nfs_home_second)
    allow(ChefVault::Item).to receive(:load).with('test_home_dir', user_with_local_home_item).and_return(user_with_local_home)
  end

  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
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
