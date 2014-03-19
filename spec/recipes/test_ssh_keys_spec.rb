require 'spec_helper'

describe 'users_test::test_ssh_keys' do
  before do
    ChefSpec::Server.create_data_bag('test_ssh_keys',
                                     shareduser: {
                                       id: 'shareduser',
                                       groups: ['sharedgroup'],
                                       ssh_keys: ['ssh-rsa KEY @shareduser'],
                                       extra_ssh_keys: {
                                         from_users: ['userone'],
                                         from_groups: ['grouptwo']
                                       }
                                     },
                                     userone: {
                                       id: 'userone',
                                       groups: ['groupone'],
                                       ssh_public_key: 'ssh-rsa KEY @userone',
                                       ssh_private_key: '-----BEGIN RSA PRIVATE KEY-----\nKEY@userone'
                                     },
                                     usertwo: {
                                       id: 'usertwo',
                                       groups: ['grouptwo'],
                                       ssh_public_key: 'ssh-rsa KEY @usertwo',
                                       ssh_private_key: '-----BEGIN RSA PRIVATE KEY-----\nKEY@usertwo'
                                     })
  end

  let(:chef_run) do
    ChefSpec::Runner.new(
      step_into: ['users_manage'],
      platform: 'ubuntu',
      version: '12.04'
    ).converge(described_recipe)
  end

  let(:authorized_files_for_shareduser) do
    'ssh-rsa KEY @shareduser
ssh-rsa KEY @userone
ssh-rsa KEY @usertwo
'
  end

  context 'Resource "users_manage"' do
    it 'creates users' do
      %w(userone usertwo shareduser).each do |u|
        expect(chef_run).to create_user(u)
      end
    end

    it 'creates correct "authorized_keys" file for shareduser' do
      expect(chef_run).to create_template('/home/shareduser/.ssh/authorized_keys')
      expect(chef_run).to render_file('/home/shareduser/.ssh/authorized_keys')
        .with_content(authorized_files_for_shareduser)
    end

    it 'creates .ssh dirs for every user' do
      %w(userone usertwo shareduser).each do |u|
        expect(chef_run).to create_directory("/home/#{u}/.ssh")
      end
    end

    it 'creates public ssh key for userone and usertwo' do
      %w(userone usertwo).each do |u|
        expect(chef_run).to create_template("/home/#{u}/.ssh/id_rsa.pub")
        expect(chef_run).to render_file("/home/#{u}/.ssh/id_rsa.pub")
          .with_content("ssh-rsa KEY @#{u}")
      end
    end

    it 'creates "authorized_keys" file for userone and usertwo' do
      %w(userone usertwo).each do |u|
        expect(chef_run).to create_template("/home/#{u}/.ssh/authorized_keys")
        expect(chef_run).to render_file("/home/#{u}/.ssh/authorized_keys")
          .with_content("ssh-rsa KEY @#{u}")
      end
    end

    it 'creates private ssh key for userone and usertwo' do
      %w(userone usertwo).each do |u|
        expect(chef_run).to create_template("/home/#{u}/.ssh/id_rsa")
        expect(chef_run).to render_file("/home/#{u}/.ssh/id_rsa")
          .with_content(/^-----BEGIN RSA PRIVATE KEY.*@#{u}$/)
      end
    end

    it 'creates groups for every user' do
      %w(groupone grouptwo sharedgroup).each do |g|
        expect(chef_run).to create_group(g)
      end
    end

    it 'manages groups' do
      %w(groupone grouptwo sharedgroup).each do |g|
        expect(chef_run).to create_users_manage(g)
      end
    end

  end # context
end # describe
