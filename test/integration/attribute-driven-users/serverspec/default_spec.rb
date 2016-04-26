require 'spec_helper'

describe user('sysadmin_2') do
  	it { should exist }
end

describe user('sysadmin') do
  	it { should_not exist }
end
