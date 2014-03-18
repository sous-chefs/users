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
  end
end

Chef::Resource.send(:include, ::Users::Helpers)
Chef::Provider.send(:include, ::Users::Helpers)
