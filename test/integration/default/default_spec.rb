os_family = os.family

describe user('test_user') do
  it { should exist }
  its('uid') { should eq 9001 } unless os_family == 'darwin'
  case os_family
  when 'suse'
    its('groups') { should eq %w( users testgroup nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'testgroup' }
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( test_user testgroup nfsgroup ) }
  end
  its('shell') { should eq '/bin/bash' }
end

describe group('testgroup') do
  it { should exist }
  its('gid') { should eq 3000 }
end

describe group('nfsgroup') do
  it { should exist }
  its('gid') { should eq 4000 }
end

describe user('test_user_keys_from_url') do
  it { should exist }
  its('uid') { should eq 9002 } unless os_family == 'darwin'
  case os_family
  when 'suse'
    its('groups') { should eq %w( users testgroup nfsgroup ) }
  when 'darwin'
    its('groups') { should include 'testgroup' }
    its('groups') { should include 'nfsgroup' }
  else
    its('groups') { should eq %w( test_user_keys_from_url testgroup nfsgroup ) }
  end
  its('shell') { should eq '/bin/bash' }
end

# NOTE: this test is super brittle and should probably create a specific github
# user or mock an HTTP server with the keys
ssh_keys = [
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy3cbPekJYHAIa8J1fOr2iIqpx/7pl4giJYAG7HCfsunRRUq3dY1KhVw1BlmMGIDzNwcuNVIfBS5HS/wREqbHMXxbwAjWrMwUofWd09CTuKJZiyTLUC5pSQWKDXZrefH/Fwd7s+YKk1s78b49zkyDcHSnKxjN+5veinzeU+vaUF9duFAJ9OsL7kTDEzOUU0zJdSdUV0hH1lnljnvk8kXHLFl9sKS3iM2LRqW4B6wOc2RbXUnx+jwNaBsq1zd73F2q3Ta7GXdtW/q4oDYl3s72oW4ySL6TZfpLCiv/7txHicZiY1eqc591CON0k/Rh7eR7XsphwkUstoUPQcBuLqQPA529zBigD7A8PBmeHISxL2qirWjR2+PrEGn1b0yu8IHHz9ZgliX83Q4WpjXvJ3REj2jfM8hiFRV3lA/ovjQrmLLV8WUAZ8updcLE5mbhZzIsC4U/HKIJS02zoggHGHZauClwwcdBtIJnJqtP803yKNPO2sDudTpvEi8GZ8n6jSXo/N8nBVId2LZa5YY/g/v5kH0akn+/E3jXhw4CICNW8yICpeJO8dGYMOp3Bs9/cRK8QYomXqgpoFlvkgzT2h4Ie6lyRgNv5QnUyAnW43O5FdBnPk/XZ3LA462VU3uOfr0AQtEJzPccpFC6OCFYWdGwZQA/r1EZQES0yRfJLpx+uZQ==',
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy3cbPekJYHAIa8J1fOr2iIqpx/7pl4giJYAG7HCfsunRRUq3dY1KhVw1BlmMGIDzNwcuNVIfBS5HS/wREqbHMXxbwAjWrMwUofWd09CTuKJZiyTLUC5pSQWKDXZrefH/Fwd7s+YKk1s78b49zkyDcHSnKxjN+5veinzeU+vaUF9duFAJ9OsL7kTDEzOUU0zJdSdUV0hH1lnljnvk8kXHLFl9sKS3iM2LRqW4B6wOc2RbXUnx+jwNaBsq1zd73F2q3Ta7GXdtW/q4oDYl3s72oW4ySL6TZfpLCiv/7txHicZiY1eqc591CON0k/Rh7eR7XsphwkUstoUPQcBuLqQPA529zBigD7A8PBmeHISxL2qirWjR2+PrEGn1b0yu8IHHz9ZgliX83Q4WpjXvJ3REj2jfM8hiFRV3lA/ovjQrmLLV8WUAZ8updcLE5mbhZzIsC4U/HKIJS02zoggHGHZauClwwcdBtIJnJqtP803yKNPO2sDudTpvEi8GZ8n6jSXo/N8nBVId2LZa5YY/g/v5kH0akn+/E3jXhw4CICNW8yICpeJO8dGYMOp3Bs9/cRK8QYomXqgpoFlvkgzT2h4Ie6lyRgNv5QnUyAnW43O5FdBnPk/XZ3LA462VU3uOfr0AQtEJzPccpFC6OCFYWdGwZQA/r1EZQES0yRfJLpx+uZQ==',
]

describe file('/home/test_user_keys_from_url/.ssh/authorized_keys') do
  ssh_keys.each do |key|
    its('content') { should include(key) }
  end
end unless os_family == 'darwin' # InSpec runs as non-root and can't see these files
