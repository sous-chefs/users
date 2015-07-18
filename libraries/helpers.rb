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

    def manage_home_files?(home_dir, user)
      # Don't manage home dir if it's NFS mount
      # and manage_nfs_home_dirs is disabled
      if home_dir == "/dev/null"
        false
      elsif fs_remote?(home_dir)
        new_resource.manage_nfs_home_dirs ? true : false
      else
        true
      end
    end

    def create_user u, cb = nil
      u['username'] ||= u['id']

      if node['apache'] and node['apache']['allowed_openids']
        Array(u['openid']).compact.each do |oid|
          node.default['apache']['allowed_openids'] << oid unless node['apache']['allowed_openids'].include?(oid)
        end
      end

      # Set home_basedir based on platform_family
      case node['platform_family']
      when 'mac_os_x'
        home_basedir = '/Users'
      when 'debian', 'rhel', 'fedora', 'arch', 'suse', 'freebsd'
        home_basedir = '/home'
      end

      # Set home to location in data bag,
      # or a reasonable default ($home_basedir/$user).
      if u['home']
        home_dir = u['home']
      else
        home_dir = "#{home_basedir}/#{u['username']}"
      end

      # The user block will fail if the group does not yet exist.
      # See the -g option limitations in man 8 useradd for an explanation.
      # This should correct that without breaking functionality.
      if u['gid'] and u['gid'].kind_of?(Numeric)
        group u['username'] do
          gid u['gid']
        end
      end

      # Create user object.
      # Do NOT try to manage null home directories.
      user u['username'] do
        uid u['uid']
        if u['gid']
          gid u['gid']
        end
        shell u['shell']
        comment u['comment']
        password u['password'] if u['password']
        if home_dir == "/dev/null"
          supports :manage_home => false
        else
          supports :manage_home => true
        end
        home home_dir
        action u['action'] if u['action']
      end

      if manage_home_files?(home_dir, u['username'])
        Chef::Log.debug("Managing home files for #{u['username']}")

        directory "#{home_dir}/.ssh" do
          owner u['username']
          group u['gid'] || u['username']
          mode "0700"
        end

        if u['ssh_keys']
          template "#{home_dir}/.ssh/authorized_keys" do
            source "authorized_keys.erb"
            cookbook cb if cb
            owner u['username']
            group u['gid'] || u['username']
            mode "0600"
            variables :ssh_keys => u['ssh_keys']
          end
        end

        if u['ssh_private_key']
          key_type = u['ssh_private_key'].include?("BEGIN RSA PRIVATE KEY") ? "rsa" : "dsa"
          template "#{home_dir}/.ssh/id_#{key_type}" do
            source "private_key.erb"
            cookbook cb if cb
            owner u['id']
            group u['gid'] || u['id']
            mode "0400"
            variables :private_key => u['ssh_private_key']
          end
        end

        if u['ssh_public_key']
          key_type = u['ssh_public_key'].include?("ssh-rsa") ? "rsa" : "dsa"
          template "#{home_dir}/.ssh/id_#{key_type}.pub" do
            source "public_key.pub.erb"
            cookbook cb if cb
            owner u['id']
            group u['gid'] || u['id']
            mode "0400"
            variables :public_key => u['ssh_public_key']
          end
        end
      else
        Chef::Log.debug("Not managing home files for #{u['username']}")
      end
    end
  end
end

Chef::Resource.send(:include, ::Users::Helpers)
Chef::Provider.send(:include, ::Users::Helpers)
