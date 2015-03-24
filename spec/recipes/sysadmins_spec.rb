require 'chef-vault'
require 'spec_helper'

describe 'users::sysadmins' do

  cached(:chef_run) do
    ChefSpec::SoloRunner.new(
      step_into: ['users_manage'],
      platform: 'ubuntu',
      version: '12.04'
    ).converge(described_recipe)
  end

  let(:createme) { { 'id' => 'createme', 'groups' => ['sysadmin'], 'uid' => 1234, 'gid' => 4321 } }
  let(:removeme) { { 'id' => 'removeme', 'groups' => ['sysadmin'], 'action' => 'remove' } }
  let(:createdevnull) { { 'id' => 'createdevnull', 'groups' => ['sysadmin'], 'home' => '/dev/null' } }
  let(:lockme) { { 'id' => 'lockme', 'groups' => ['sysadmin'], 'action' => 'lock'} }
  let(:skipme) { { 'id' => 'skipme', 'groups' => ['nonadmin'] } }

  let(:createme_item) { 'createme' }
  let(:removeme_item) { 'removeme' }
  let(:createdevnull_item) { 'createdevnull' }
  let(:lockme_item) { 'lockme' }
  let(:skipme_item) { 'skipme' }

  let(:data_bag_items) { [createme_item, removeme_item, createdevnull_item, lockme_item, skipme_item] }

  before do
     stub_data_bag('users').and_return(data_bag_items)
     allow(ChefVault::Item).to receive(:load).with('users', createme_item).and_return(createme)
     allow(ChefVault::Item).to receive(:load).with('users', removeme_item).and_return(removeme)
     allow(ChefVault::Item).to receive(:load).with('users', createdevnull_item).and_return(createdevnull)
     allow(ChefVault::Item).to receive(:load).with('users', lockme_item).and_return(lockme)
     allow(ChefVault::Item).to receive(:load).with('users', skipme_item).and_return(skipme)
  end

  context 'Resource "users_manage"' do
    it 'manages users from "sysadmin" group' do
      expect(chef_run).to create_users_manage('sysadmin')
      expect(chef_run).to remove_users_manage('sysadmin')

      expect(chef_run).to_not create_users_manage('nonadmin')
      expect(chef_run).to_not remove_users_manage('nonadmin')
    end

    it 'creates user "createme"' do
      expect(chef_run).to create_user('createme')
        .with_uid(1234)
        .with_gid(4321)
        .with_home('/home/createme')
      expect(chef_run).to create_directory('/home/createme/.ssh')
    end

    it 'creates user "createdevnull"' do
      expect(chef_run).to create_user('createdevnull')
        .with_home('/dev/null')
      expect(chef_run).to_not create_directory('/dev/null/.ssh')
    end

    it 'creates group "createme"' do
      expect(chef_run).to create_group('createme')
        .with_gid(4321)
    end

    it 'creates group "sysadmin"' do
      expect(chef_run).to create_group('sysadmin')
        .with_gid(2300)
    end

    it 'skips creating user "skipme"' do
      expect(chef_run).to_not create_user('skipme')
    end

    it 'locks user "lockme"' do
      expect(chef_run).to lock_user('lockme')
      expect(chef_run).to create_directory('/home/lockme/.ssh')
    end

    it 'removes user "removeme"' do
      expect(chef_run).to remove_user('removeme')
    end
  end
end
