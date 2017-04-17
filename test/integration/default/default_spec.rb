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
