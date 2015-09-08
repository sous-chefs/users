require 'spec_helper'

describe 'users::sysadmins' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new(
      step_into: ['users_manage'],
      platform: 'ubuntu',
      version: '12.04'
    ) do |_node, server|
      server.create_data_bag('users', createme: {
                               id: 'createme',
                               groups: ['sysadmin'],
                               uid: 1234,
                               gid: 4321
                             },
                                      removeme: {
                                        id: 'removeme',
                                        groups: ['sysadmin'],
                                        action: :remove
                                      },
                                      createdevnull: {
                                        id: 'createdevnull',
                                        groups: ['sysadmin'],
                                        home: '/dev/null'
                                      },
                                      lockme: {
                                        id: 'lockme',
                                        groups: ['sysadmin'],
                                        action: :lock
                                      },
                                      skipme: {
                                        id: 'skipme',
                                        groups: ['nonadmin']
                                      })
    end.converge(described_recipe)
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
