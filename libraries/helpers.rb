require 'mixlib/shellout'

module Users
  # Helpers for Users
  module Helpers
    # Checks fs type.
    #
    # @return [String]
    def fs_type(mount)
      begin
        # Doesn't support macosx
        stat = Mixlib::ShellOut.new("stat -f -L -c %T #{mount} 2>&1").run_command
        stat.stdout.chomp
      rescue
        'none'
      end
    end

    # Determines if provided mount point is remote.
    #
    # @return [Boolean]
    def fs_remote?(mount)
      fs_type(mount) == 'nfs' ? true : false
    end

    def users_list(data_bag_name)
      begin
        require 'chef-vault'
      rescue LoadError
        Chef::Log.warn("Missing gem 'chef-vault', use recipe[chef-vault] to install it first.")
      end

      user_items = []
      data_bag(data_bag_name).each do |user|
        user_items << chef_vault_item("#{data_bag_name}", "#{user}")
      end

      user_items
    end
  end
end

Chef::Resource.send(:include, ::Users::Helpers)
Chef::Provider.send(:include, ::Users::Helpers)
