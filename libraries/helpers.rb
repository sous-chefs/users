module Users
  # Helpers for Users
  module Helpers
    # Checks fs type.
    #
    # @return [String]
    def fs_type(mount)
      # Doesn't support macosx
      stat = shell_out("stat -f -L -c %T #{mount} 2>&1")
      stat.stdout.chomp
    rescue
      'none'
    end

    # Determines if provided mount point is remote.
    #
    # @return [Boolean]
    def fs_remote?(mount)
      fs_type(mount) == 'nfs'
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
    def shell_is_valid?(shell_path)
      return false if shell_path.nil? || !File.exist?(shell_path)
      # AIX is the only OS that has the concept of 'approved shells'
      return true unless platform_family?('aix')

      begin
        File.open('/etc/security/login.cfg') do |f|
          f.each_line do |l|
            l.match(/^\s*shells\s*=\s*(.*)/) do |m|
              return true if m[1].split(/\s*,\s*/).any? { |entry| entry.eql? shell_path }
            end
          end
        end
      rescue
        return false
      end

      false
    end

    # Returns the appropriate base user home directory per platform
    #
    # @return [String]
    def home_basedir
      if platform_family?('mac_os_x')
        '/Users'
      elsif platform_family?('solaris2')
        '/export/home'
      else
        '/home'
      end
    end

    # Returns the type of the public key or rsa
    #
    # @return [String]
    def pubkey_type(pubkey)
      %w(ed25519 ecdsa dss rsa dsa).filter { |kt| pubkey.split.first.include?(kt) }.first || 'rsa'
    end

    # Returns a bool, deciding wether a username group must be created for a user
    #
    # @return [Bool]
    def creates_user_group?(user)
      !(platform_family?('suse', 'mac_os_x') || user[:no_user_group])
    end

    # Returns a bool, deciding wether a custom primary group must be created for a user
    #
    # @return [Bool]
    def creates_primary_group?(user)
      user[:gid] && !username_is_primary?(user) && !primary_gid(user).is_a?(Numeric)
    end

    # Returns a bool, deciding whether a users primary group is its username group based on their user hash
    #
    # @return [Bool]
    def username_is_primary?(user)
      if user[:gid]
        user[:gid].is_a?(Numeric) && user[:primary_group].nil? && creates_user_group?(user)
      else
        creates_user_group?(user)
      end
    end

    # Returns the name of a users primary group or an integer gid if a string isnt provided
    # If a user hash contains an integer gid it defaults to the username group, assigning that gid.
    # If a primary group is also passed than that group will be assigned the gid instead.
    #
    # @return [String, Integer]
    def primary_gid(user)
      if user[:gid].is_a?(Numeric)
        user[:primary_group] || user[:gid].to_i
      else
        user[:gid]
      end
    end

    # Returns the default user group based on os. On linux this group is the username group
    #
    # @return [String]
    def get_default_group(user)
      case node['platform_family']
      when 'suse'
        'users'
      when 'mac_os_x'
        'staff'
      else
        user[:username] || user[:id]
      end
    end
  end
end
