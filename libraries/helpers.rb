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

    def keys_from_url(url)
      host = url.split('/')[0..2].join('/')
      path = url.split('/')[3..-1].join('/')
      begin
        response = Chef::HTTP.new(host).get(path)
        response.split("\n")
      rescue Net::HTTPServerException => e
        p "request: #{host}#{path}, error: #{e}"
      end
    end

    # Determines if the user's shell is valid on the machine, otherwise
    # returns the default of /bin/sh
    #
    # @return [String]
    def valid_shell(shell)
      shell_exists = File.exist?(shell)
      # A check to see if the shell exists on the system
      if !shell_exists
        log "Shell #{shell} not found - defaulting to /bin/sh"
        return '/bin/sh'
      else
        # Disabling some rules because it really doesn't help the readablility
        # of this section
        # rubocop:disable Style/GuardClause
        # rubocop:disable Style/IfInsideElse
        if platform_family?('aix')
          # On AIX a shell may exist but not be one of the 'approved' shells.
          # There is no cli based tool to determine this, so we go directly to the
          # source and use this nasty regex to extract all possible 'allowed' shells
          # and verify based on equality. (if it doesn't exist it will return nil
          # and drop through)
          shell_avail = Mixlib::ShellOut.new("cat /etc/security/login.cfg | grep #{shell}").run_command
          if (shell_avail.stdout.scan %r{([\/\w-]*)}).uniq.flatten.any? { |entry| entry.eql? shell }
            return shell
          else
            return '/bin/sh'
          end
        else
          return shell
        end
      end
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
      elsif platform_family?('solaris2')
        '/export/home'
      else
        '/home'
      end
    end
  end
end
