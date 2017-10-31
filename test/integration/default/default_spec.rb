describe user('test_user') do
  it { should exist }
  its('uid') { should eq 9001 }
  its('groups') { should eq %w( test_user testgroup nfsgroup ) }
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
  its('uid') { should eq 9002 }
  its('groups') { should eq %w( test_user_keys_from_url testgroup nfsgroup ) }
  its('shell') { should eq '/bin/bash' }
end

# NOTE: this test is super brittle and should probably create a specific github
# user or mock an HTTP server with the keys
ssh_keys = [
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4j6wHVxbs1FQXxV4DaG6RyXMgHfxTSB0tb2uA2Z8kNy9mwZ14zvT9kUCyniXwwTcxbGsxXtjR7qOKrhU0dUnyEu0k2dKIbg8lwkI7aILRnc8wmN7mhoLKifCDlcrNRhhtUjZFVd3Ddmvz8vVOOMElnTQUSy9bw8/WWN2LodFba4RN+9DdIG6nW8bjDbfD5+9jQMHDRbmyBh7FAOe1+T4AowjqRiPuwpxEs7YasQJCHgug0LR1vKF7ufPdUMmv7PxL5kWnZbwis58X/vzfPpOP4VMmhBWLhthrVEz7YFWByguHdnABdX3qM1lEHmb/B+trM7H0qd00Fx5Mg2YxrKOv2pxwX03yDWaJpZSk6WOueKOwPgd5BvOrJ6yZLT7KUJ4NgxnpKWJckoXyy5QfG89G1BWsaEXXQbzxLYLszYzi5YUnRxhZs6cljlGkkoU6qkcUyYcfQ2/7Gp2ElHOnIIQE5m5Tl8yCwGeumt9dwVgxRmVVLidu/NGFhjuQ2Th15V1mVGKPe4xibJATPJILzNPKAekAZqTFRlUm7+rTmg4+a8zWRGpkjq2mPF+pNvlqXFMXBMSleV9CWSpjyZqQI0tNCBUd8kE0ZR3Zn7OxXUvcanh5cgYRHiSeK10TKSd7BkzNUponUZTymZmHyeYLBZ8U1i83VJpQxQGOWbItJdD6MQ==',
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCy3cbPekJYHAIa8J1fOr2iIqpx/7pl4giJYAG7HCfsunRRUq3dY1KhVw1BlmMGIDzNwcuNVIfBS5HS/wREqbHMXxbwAjWrMwUofWd09CTuKJZiyTLUC5pSQWKDXZrefH/Fwd7s+YKk1s78b49zkyDcHSnKxjN+5veinzeU+vaUF9duFAJ9OsL7kTDEzOUU0zJdSdUV0hH1lnljnvk8kXHLFl9sKS3iM2LRqW4B6wOc2RbXUnx+jwNaBsq1zd73F2q3Ta7GXdtW/q4oDYl3s72oW4ySL6TZfpLCiv/7txHicZiY1eqc591CON0k/Rh7eR7XsphwkUstoUPQcBuLqQPA529zBigD7A8PBmeHISxL2qirWjR2+PrEGn1b0yu8IHHz9ZgliX83Q4WpjXvJ3REj2jfM8hiFRV3lA/ovjQrmLLV8WUAZ8updcLE5mbhZzIsC4U/HKIJS02zoggHGHZauClwwcdBtIJnJqtP803yKNPO2sDudTpvEi8GZ8n6jSXo/N8nBVId2LZa5YY/g/v5kH0akn+/E3jXhw4CICNW8yICpeJO8dGYMOp3Bs9/cRK8QYomXqgpoFlvkgzT2h4Ie6lyRgNv5QnUyAnW43O5FdBnPk/XZ3LA462VU3uOfr0AQtEJzPccpFC6OCFYWdGwZQA/r1EZQES0yRfJLpx+uZQ==',
]

describe file('/home/test_user_keys_from_url/.ssh/authorized_keys') do
  ssh_keys.each do |key|
    its('content') { should include(key) }
  end
end
