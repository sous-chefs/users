module Users
  # Helpers for Users
  module OSX_helper
    def dscl(*args)
      host = "."
      stdout_result = ""; stderr_result = ""; cmd = "dscl #{host} -#{args.join(' ')}"
      status = shell_out(cmd)
      status.stdout.each_line { |line| stdout_result << line }
      status.stderr.each_line { |line| stderr_result << line }
      return [cmd, status, stdout_result, stderr_result]
    end

    def safe_dscl(*args)
      result = dscl(*args)
      return "" if ( args.first =~ /^delete/ ) && ( result[1].exitstatus != 0 )
      raise(Chef::Exceptions::Group, "dscl error: #{result.inspect}") unless result[1].exitstatus == 0
      raise(Chef::Exceptions::Group, "dscl error: #{result.inspect}") if result[2] =~ /No such key: /
      return result[2]
    end

    def gid_used?(gid)
       return false unless gid
       groups_gids = safe_dscl("list /Groups gid")
       !! ( groups_gids =~ Regexp.new("#{Regexp.escape(gid.to_s)}\n") )
    end
  end
end

Chef::Resource.send(:include, ::Users::OSX_helper)
Chef::Provider.send(:include, ::Users::OSX_helper)
