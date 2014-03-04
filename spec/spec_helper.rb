require 'berkshelf'
require 'chefspec'
require 'chefspec/server'

# Vendor all required cookbooks for chef-zero
FileUtils.remove_dir('vendor/cookbooks', force: true)
Berkshelf.ui.mute do
  Berkshelf::Berksfile.from_file('Berksfile').vendor('vendor/cookbooks')
end

# Point chef-zero at vendored cookbooks
RSpec.configure do |config|
  config.cookbook_path = 'vendor/cookbooks'
end

at_exit { ChefSpec::Coverage.report! }
