sudo "sysadmin" do
    user "%sysadmin"
    host "ALL"
    commands ["ALL"]
    nopasswd false
end

case node["platform"]
when "ubuntu"
    sudo "ubuntu" do
        user "ubuntu"
        host "ALL"
        commands ["ALL"]
        nopasswd true 
    end
    sudo "admin" do
        user "%admin"
        host "ALL"
        commands ["ALL"]
        nopasswd true
    end
when "amazon"
    sudo "ec2-user" do
        user "ec2-user"
        host "ALL"
        commands ["ALL"]
        nopasswd true
    end
    sudo "wheel" do
        user "%wheel"
        host "ALL"
        commands ["ALL"]
        nopasswd true
    end
end
