require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'

RSpec.configure do |config|
  config.log_level = :warn
end

ChefSpec::Coverage.start!
