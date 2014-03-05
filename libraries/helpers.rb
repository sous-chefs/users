module Users
  # Helpers for Users
  module Helpers
    # Checks fs type.
    #
    # @return [String]
    def fs_type(mount)
      # Set home_basedir based on platform_family
      if node['platform_family'] == 'mac_os_x'
        # Does't not support macosx FS type recognition yet
        # Always set to local type
        type = 'ext2/ext3'
      else
        type = `stat -f -L -c %T #{mount} 2>&1`.chomp
      end

      if type =~ /No such file or directory/
        'none'
      else
        type
      end
    end

    # Determines if provided mount point is local.
    #
    # @return [Boolean]
    def fs_local?(mount)
      case fs_type(mount)
      when 'ext2/ext3'
        true
      when 'nfs'
        false
      else
        bail_out("Cannot determine filesystem type for \"#{mount}\"")
      end
    end

    # Determines if provided mount point is remote.
    #
    # @return [Boolean]
    def fs_remote?(mount)
      case fs_type(mount)
      when 'ext2/ext3'
        false
      when 'nfs'
        true
      else
        bail_out("Cannot determine filesystem type for \"#{mount}\"")
      end
    end

    # Bails out of chef-run.
    #
    def bail_out(msg)
      Chef::Log.fatal(msg)
      ruby_block "bailing-out" do
        block do
          exit!(1)
        end
        action :create
      end.run_action(:create)
    end

  end
end

Chef::Resource.send(:include, ::Users::Helpers)
Chef::Provider.send(:include, ::Users::Helpers)