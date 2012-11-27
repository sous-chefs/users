case node['platform']
when "ubuntu","debian"
    update = execute "apt-get update" do
	action :nothing
    end

    update.run_action(:run)

    %w{build-essential binutils-doc}.each do |pkg|
	to_install = package pkg do
	    action :nothing
	end
	to_install.run_action(:install)
    end
when "centos","redhat","fedora","amazon"
    %w{gcc gcc-c++ kernel-devel make}.each do |pkg|
	to_install = package pkg do
	    action :nothing
	    not_if 'which gcc > /dev/null'
	end
	to_install.run_action(:install)
    end
end

chef_gem "ruby-shadow"

users_manage "sftp-only" do
    group_id 10001
    action [ :remove, :create ]
end

deny_users = Array.new
search("users", "vsftpd.deny_user:true") do |user|
    deny_users.push(user[:id])
end

template "/etc/vsftpd.deny_users" do
    source "vsftpd.deny_users.erb"
    mode 644
    owner 'root'
    group 'root'
    variables({
	:users => deny_users
    })
end
