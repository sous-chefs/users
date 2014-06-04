require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'
require 'chefspec/server'

RSpec.configure do |config|
  config.log_level = :warn
end

ChefSpec::Coverage.start!
