class Chef
  class Provider
    class Group
      class Usermod < Chef::Provider::Group::Groupadd
       
        def modify_group_members
          case node[:platform]
          when "openbsd", "netbsd", "aix", "solaris2", "smartos"
            append_flags = "-G"
          when "solaris"
            append_flags = "-a -G"
          end

          unless @new_resource.members.empty?
            if(@new_resource.append)
              @new_resource.members.each do |member|
                Chef::Log.debug("#{@new_resource} appending member #{member} to group #{@new_resource.group_name}")
                run_command(:command => "usermod #{append_flags} #{@new_resource.group_name} #{member}" )
              end
            end
          else
            Chef::Log.debug("#{@new_resource} not changing group members, the group has no members")
          end
        end
      end
    end
  end
end