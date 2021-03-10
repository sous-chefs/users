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
  case os_family
  when 'suse'
    its('groups') { should eq %w( users nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( user_with_dev_null_home nfsgroup ) }
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
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files

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
  end
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files
