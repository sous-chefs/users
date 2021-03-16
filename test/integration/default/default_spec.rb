os_family = os.family

# Test if the groups exist
describe group('testgroup') do
  it { should exist }
  its('gid') { should eq 3000 }
end

describe group('nfsgroup') do
  it { should exist }
  its('gid') { should eq 4000 }
end

# Test users from attributes
describe user('usertoremove') do
  it { should_not exist }
end

describe user('user_with_dev_null_home') do
  it { should exist }
  its('uid') { should eq 5000 } unless os_family == 'darwin'
  its('gid') { should eq 4000 } unless os_family == 'darwin'
  case os_family
  when 'suse'
    its('groups') { should eq %w( nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( nfsgroup ) }
  end
  its('shell') { should eq '/bin/bash' }
end

describe user('user_with_nfs_home_first') do
  it { should exist }
  case os_family
  when 'suse'
    its('groups') { should eq %w( users nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( user_with_nfs_home_first nfsgroup ) }
  end
  its('shell') { should eq '/bin/sh' }
end

describe file('/home/user_with_nfs_home_first/.ssh/id_ed25519.pub') do
  its('content') { should include('ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6aZDF+x28xIlZSgyfyh3IAkencLp1VCU7JXBhJcXNy cheftestuser@laptop') }
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files

describe user('user_with_nfs_home_second') do
  it { should exist }
  case os_family
  when 'suse'
    its('groups') { should eq %w( users nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( user_with_nfs_home_second nfsgroup ) }
  end
  its('shell') { should eq '/bin/sh' }
end

describe file('/home/user_with_nfs_home_second/.ssh/id_ecdsa') do
  it { should exist }
  its('content') { should include("-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAaAAAABNlY2RzYS\n1zaGEyLW5pc3RwMjU2AAAACG5pc3RwMjU2AAAAQQQns8Ec3poQBm6r7zv/UZojvXjrUZVB\n59R4LzOBw8cS/2xSQrVH8qm2X8kB1y6nuyydK0bbQF1pnES1P+uvG6e9AAAAsD2Nf449jX\n+OAAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCezwRzemhAGbqvv\nO/9RmiO9eOtRlUHn1HgvM4HDxxL/bFJCtUfyqbZfyQHXLqe7LJ0rRttAXWmcRLU/668bp7\n0AAAAgJp/B6o2OADM0+NlkgH1dFcOLK64jhr3ScbWK4iyRdOcAAAAVZm11bGxlckBzYnBs\ndGMxbWxsdmRsAQID\n-----END OPENSSH PRIVATE KEY-----\n") }
  its('owner') { should eq 'user_with_nfs_home_second' }
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files

describe file('/home/user_with_nfs_home_second/.ssh/id_ecdsa.pub') do
  it { should exist }
  its('content') { should include('ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCezwRzemhAGbqvvO/9RmiO9eOtRlUHn1HgvM4HDxxL/bFJCtUfyqbZfyQHXLqe7LJ0rRttAXWmcRLU/668bp70=') }
  its('owner') { should eq 'user_with_nfs_home_second' }
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files

describe user('user_with_local_home') do
  it { should exist }
  case os_family
  when 'suse'
    its('groups') { should eq %w( users nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( user_with_local_home nfsgroup ) }
  end
  its('shell') { should eq '/bin/sh' }
end

describe directory('/home/user_with_local_home') do
  it { should exist }
  its('owner') { should eq 'user_with_local_home' }
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files

describe file('/home/user_with_local_home/.ssh/id_rsa') do
  it { should exist }
  its('content') { should include("-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW\nQyNTUxOQAAACAummQxfsdvMSJWUoMn8odyAJHp3C6dVQlOyVwYSXFzcgAAAJjzcJxA83Cc\nQAAAAAtzc2gtZWQyNTUxOQAAACAummQxfsdvMSJWUoMn8odyAJHp3C6dVQlOyVwYSXFzcg\nAAAEC7TGfA0MU0mh0V39qw5RSThUo0idTtU2vCe9bJrHmyFS6aZDF+x28xIlZSgyfyh3IA\nkencLp1VCU7JXBhJcXNyAAAAFWZtdWxsZXJAc2JwbHRjMW1sbHZkbA==\n-----END OPENSSH PRIVATE KEY-----\n") }
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files

describe user('user_with_username_instead_of_id') do
  it { should exist }
  case os_family
  when 'suse'
    its('groups') { should eq %w( users nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( user_with_username_instead_of_id nfsgroup ) }
  end
  its('shell') { should eq '/bin/bash' }
end

describe directory('/home/user_with_username_instead_of_id') do
  it { should exist }
  its('owner') { should eq 'user_with_username_instead_of_id' }
end unless os_family == 'darwin'

describe directory('/home/user_with_username_instead_of_id/.ssh') do
  it { should exist }
  its('owner') { should eq 'user_with_username_instead_of_id' }
end unless os_family == 'darwin'

describe file('/home/user_with_username_instead_of_id/.ssh/authorized_keys') do
  it { should exist }
  its('owner') { should eq 'user_with_username_instead_of_id' }
  its('content') { should include('ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6aZDF+x28xIlZSgyfyh3IAkencLp1VCU7JXBhJcXNy cheftestuser@laptop') }
end unless os_family == 'darwin'

describe file('/home/user_with_username_instead_of_id/.ssh/id_ecdsa') do
  it { should exist }
  its('owner') { should eq 'user_with_username_instead_of_id' }
  its('content') { should include("-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW\nQyNTUxOQAAACAummQxfsdvMSJWUoMn8odyAJHp3C6dVQlOyVwYSXFzcgAAAJjzcJxA83Cc\nQAAAAAtzc2gtZWQyNTUxOQAAACAummQxfsdvMSJWUoMn8odyAJHp3C6dVQlOyVwYSXFzcg\nAAAEC7TGfA0MU0mh0V39qw5RSThUo0idTtU2vCe9bJrHmyFS6aZDF+x28xIlZSgyfyh3IA\nkencLp1VCU7JXBhJcXNyAAAAFWZtdWxsZXJAc2JwbHRjMW1sbHZkbA==\n-----END OPENSSH PRIVATE KEY-----\n") }
end unless os_family == 'darwin'

describe file('/home/user_with_username_instead_of_id/.ssh/id_ecdsa.pub') do
  it { should exist }
  its('owner') { should eq 'user_with_username_instead_of_id' }
  its('content') { should include('ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCezwRzemhAGbqvvO/9RmiO9eOtRlUHn1HgvM4HDxxL/bFJCtUfyqbZfyQHXLqe7LJ0rRttAXWmcRLU/668bp70=') }
end unless os_family == 'darwin'

# Test users from databags
describe user('databag_mwaddams') do
  it { should_not exist }
end

describe directory('/home/databag_mwaddams') do
  it { should_not exist }
end

describe group('databag_mwaddams') do
  it { should_not exist }
end

describe user('databag_test_user') do
  it { should exist }
  its('uid') { should eq 9001 } unless os_family == 'darwin'
  case os_family
  when 'suse'
    its('groups') { should eq %w( users testgroup ) }
  when 'darwin'
    its('groups') { should include 'testgroup' }
  else
    its('groups') { should eq %w( databag_test_user testgroup ) }
  end
  its('shell') { should eq '/bin/bash' }
end

describe user('databag_test_user_keys_from_url') do
  it { should exist }
  its('uid') { should eq 9002 } unless os_family == 'darwin'
  case os_family
  when 'suse'
    its('groups') { should eq %w( users testgroup ) }
  when 'darwin'
    its('groups') { should include 'testgroup' }
  else
    its('groups') { should eq %w( databag_test_user_keys_from_url testgroup ) }
  end
  its('shell') { should eq '/bin/bash' }
end

# NOTE: this test is super brittle and should probably create a specific github
# user or mock an HTTP server with the keys
ssh_keys = [
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy3cbPekJYHAIa8J1fOr2iIqpx/7pl4giJYAG7HCfsunRRUq3dY1KhVw1BlmMGIDzNwcuNVIfBS5HS/wREqbHMXxbwAjWrMwUofWd09CTuKJZiyTLUC5pSQWKDXZrefH/Fwd7s+YKk1s78b49zkyDcHSnKxjN+5veinzeU+vaUF9duFAJ9OsL7kTDEzOUU0zJdSdUV0hH1lnljnvk8kXHLFl9sKS3iM2LRqW4B6wOc2RbXUnx+jwNaBsq1zd73F2q3Ta7GXdtW/q4oDYl3s72oW4ySL6TZfpLCiv/7txHicZiY1eqc591CON0k/Rh7eR7XsphwkUstoUPQcBuLqQPA529zBigD7A8PBmeHISxL2qirWjR2+PrEGn1b0yu8IHHz9ZgliX83Q4WpjXvJ3REj2jfM8hiFRV3lA/ovjQrmLLV8WUAZ8updcLE5mbhZzIsC4U/HKIJS02zoggHGHZauClwwcdBtIJnJqtP803yKNPO2sDudTpvEi8GZ8n6jSXo/N8nBVId2LZa5YY/g/v5kH0akn+/E3jXhw4CICNW8yICpeJO8dGYMOp3Bs9/cRK8QYomXqgpoFlvkgzT2h4Ie6lyRgNv5QnUyAnW43O5FdBnPk/XZ3LA462VU3uOfr0AQtEJzPccpFC6OCFYWdGwZQA/r1EZQES0yRfJLpx+uZQ==',
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy3cbPekJYHAIa8J1fOr2iIqpx/7pl4giJYAG7HCfsunRRUq3dY1KhVw1BlmMGIDzNwcuNVIfBS5HS/wREqbHMXxbwAjWrMwUofWd09CTuKJZiyTLUC5pSQWKDXZrefH/Fwd7s+YKk1s78b49zkyDcHSnKxjN+5veinzeU+vaUF9duFAJ9OsL7kTDEzOUU0zJdSdUV0hH1lnljnvk8kXHLFl9sKS3iM2LRqW4B6wOc2RbXUnx+jwNaBsq1zd73F2q3Ta7GXdtW/q4oDYl3s72oW4ySL6TZfpLCiv/7txHicZiY1eqc591CON0k/Rh7eR7XsphwkUstoUPQcBuLqQPA529zBigD7A8PBmeHISxL2qirWjR2+PrEGn1b0yu8IHHz9ZgliX83Q4WpjXvJ3REj2jfM8hiFRV3lA/ovjQrmLLV8WUAZ8updcLE5mbhZzIsC4U/HKIJS02zoggHGHZauClwwcdBtIJnJqtP803yKNPO2sDudTpvEi8GZ8n6jSXo/N8nBVId2LZa5YY/g/v5kH0akn+/E3jXhw4CICNW8yICpeJO8dGYMOp3Bs9/cRK8QYomXqgpoFlvkgzT2h4Ie6lyRgNv5QnUyAnW43O5FdBnPk/XZ3LA462VU3uOfr0AQtEJzPccpFC6OCFYWdGwZQA/r1EZQES0yRfJLpx+uZQ==',
]

describe file('/home/databag_test_user_keys_from_url/.ssh/authorized_keys') do
  ssh_keys.each do |key|
    its('content') { should include(key) }
    its('owner') { should eq 'databag_test_user_keys_from_url' }
  end
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files
