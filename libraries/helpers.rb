module Users
  # Helpers for Users
  module Helpers
    # Checks fs type.
    #
    # @return [String]
    def fs_type(mount)
      # Doesn't support macosx
      stat = Mixlib::ShellOut.new("stat -f -L -c %T #{mount} 2>&1").run_command
      stat.stdout.chomp
    rescue
      'none'
    end

    # Determines if provided mount point is remote.
    #
    # @return [Boolean]
    def fs_remote?(mount)
      fs_type(mount) == 'nfs' ? true : false
    end

    # Validates passed id.
    #
    # @return [Numeric, String]
    # handles checking whether uid was specified as a string
    def validate_id(id)
      id.to_i.to_s == id ? id.to_i : id
    end

    # Returns the appropriate base user home directory per platform
    #
    # @return [ String]
    def home_basedir
      if platform_family?('mac_os_x')
        '/Users'
      else
        '/home'
      end
    end
  end
end
