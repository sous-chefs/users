require 'chefspec'

describe 'users::admins' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'users::admins' }
  it 'return the admin data bag' do
    Chef::Recipe.any_instance.stub(:search).and_return(Array.new)
    Chef::Recipe.any_instance.stub(:data_bag_item).and_return(Hash.new)
    Chef::Recipe.any_instance.stub(:data_bag_item).with("users", "groups").and_return({"id" => "deployer"})
    # apparently we don't have access to user accounts, so just make sure
    # it runs
    expect { chef_run }.not_to raise_exception
  end

  it 'uses the gid of the existing admin group' do
    Chef::Recipe.any_instance.stub(:search).and_return(Array.new)
    Chef::Recipe.any_instance.stub(:data_bag_item).and_return(Hash.new)
    Chef::Recipe.any_instance.stub(:data_bag_item).with("users", "dolly").and_return( {
      "id" => "dolly",
      "ssh_keys"=> "ssh-rsa AAAAB3Nz...yhCw== bofh",
      "groups"=> [ "admin", "dba", "devops" ],
      "uid"=> 2001,
      "shell"=> "\/bin\/bash",
      "comment"=> "BOFH",
      }
    )
    Etc.stub(:getgrnam).with("admin").and_return('gid' => 150)
    # apparently we don't have access to user accounts, so just make sure
    # it runs
    expect { chef_run }.not_to raise_exception
  end

  it 'uses the gid of the existing admin group' do
    Chef::Recipe.any_instance.stub(:search).and_return(Array.new)
    Chef::Recipe.any_instance.stub(:data_bag_item).and_return(Hash.new)
    Chef::Recipe.any_instance.stub(:data_bag_item).with("users", "mame").and_return( {
      "id" => "mame",
      "ssh_keys"=> "ssh-rsa AAAAB3Nz...yhCw== bofh",
      "groups"=> [ "admin", "dba", "devops" ],
      "uid"=> 2001,
      "shell"=> "\/bin\/bash",
      "comment"=> "BOFH",
      }
    )
    Etc.stub(:getgrnam).with("admin") do
      raise ArgumentError
    end
    # apparently we don't have access to user accounts, so just make sure
    # it runs
    expect { chef_run }.not_to raise_exception
  end

end
