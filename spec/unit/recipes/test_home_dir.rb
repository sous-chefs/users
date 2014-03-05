require 'spec_helper'

describe 'users_test::test_home_dir' do
  before do
    ChefSpec::Server.create_data_bag('test_home_dir',
                                     user_with_dev_null_home: {
                                       id: 'user_with_dev_null_home',
                                       groups: ['testgroup'],
                                       home: '/dev/null'
                                     },
                                     user_with_local_home: {
                                       id: 'user_with_local_home',
                                       groups: ['testgroup']
                                     })
  end

  let(:chef_run) do
    ChefSpec::Runner.new(
      step_into: ['users_manage'],
      platform: 'ubuntu',
      version: '12.04'
    ).converge(described_recipe)
  end

  context 'Resource "users_manage"' do
    it 'creates users' do
      %w(user_with_dev_null_home user_with_local_home).each do |u|
        stub_command('echo 123').and_return('stubbed yo!')
        expect(chef_run).to create_user(u)
      end
    end

    it "not supports managing /dev/null home dir" do
      expect(chef_run).to create_user('user_with_dev_null_home')
        .with(supports: {manage_home: false})
    end

    it "supports managing local home dir" do
      expect(chef_run).to create_user('user_with_local_home')
        .with(supports: {manage_home: true})
    end

    it 'not tries to manage .ssh dir for user "user_with_dev_null_home"' do
      expect(chef_run).to_not create_directory('/dev/null')
    end

    it 'manages .ssh dir for local user' do
      expect(chef_run).to create_directory('/home/user_with_local_home/.ssh')
    end


  end # context
end # describe
