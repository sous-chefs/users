# Matchers for chefspec 3

if defined?(ChefSpec)
  def create_users_manage(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:users_manage,
                                            :create,
                                            resource_name)
  end

  def remove_users_manage(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:users_manage,
                                            :remove,
                                            resource_name)
  end
end
