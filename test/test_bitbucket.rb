require 'base64'
require_relative 'helper'

describe 'Bitbucket payload' do
  user = "deployer"
  pass = "Deploy1T"
  # payload has a known repository and branch name (aka configured)
  it 'should output webhook received - known repo and branch' do
    authorize user, pass
    post '/payload/bitbucket', 'payload' => '%7B%22repository%22%3A %7B%22website%22%3A %22%22%2C %22fork%22%3A false%2C %22name%22%3A %22puppet-control%22%2C %22scm%22%3A %22git%22%2C %22owner%22%3A %22theowner%22%2C %22absolute_url%22%3A %22%2Ftheowner%2Fpuppet-control%2F%22%2C %22slug%22%3A %22puppet-control%22%2C %22is_private%22%3A true%7D%2C %22truncated%22%3A false%2C %22commits%22%3A %5B%7B%22node%22%3A %22634d71461df8%22%2C %22files%22%3A %5B%7B%22type%22%3A %22modified%22%2C %22file%22%3A %22hooktest.txt%22%7D%5D%2C %22raw_author%22%3A %22Tobias Brunner %3Ctobias%40domain.com%3E%22%2C %22utctimestamp%22%3A %222014-12-03 16%3A04%3A36%2B00%3A00%22%2C %22author%22%3A %22tobru%22%2C %22timestamp%22%3A %222014-12-03 17%3A04%3A36%22%2C %22raw_node%22%3A %22634d71461df82f2095f18955cf967b606cb25f84%22%2C %22parents%22%3A %5B%22d94b7645874e%22%5D%2C %22branch%22%3A %22production%22%2C %22message%22%3A %22hook test 3%5Cn%22%2C %22revision%22%3A null%2C %22size%22%3A -1%7D%5D%2C %22canon_url%22%3A %22https%3A%2F%2Fbitbucket.org%22%2C %22user%22%3A %22tobru%22%7D'
    assert last_response.ok?
    assert last_response.body.must_match "webhook received"
  end
  # payload has a known repository and unknown branch (uses '_all' branch)
  it 'should output webhook received - known repo and unknown branch' do
    authorize user, pass
    post '/payload/bitbucket', 'payload' => '%7B%22repository%22%3A %7B%22website%22%3A %22%22%2C %22fork%22%3A false%2C %22name%22%3A %22puppet-control%22%2C %22scm%22%3A %22git%22%2C %22owner%22%3A %22theowner%22%2C %22absolute_url%22%3A %22%2Ftheowner%2Fpuppet-control%2F%22%2C %22slug%22%3A %22puppet-control%22%2C %22is_private%22%3A true%7D%2C %22truncated%22%3A false%2C %22commits%22%3A %5B%7B%22node%22%3A %22634d71461df8%22%2C %22files%22%3A %5B%7B%22type%22%3A %22modified%22%2C %22file%22%3A %22hooktest.txt%22%7D%5D%2C %22raw_author%22%3A %22Tobias Brunner %3Ctobias%40domain.com%3E%22%2C %22utctimestamp%22%3A %222014-12-03 16%3A04%3A36%2B00%3A00%22%2C %22author%22%3A %22tobru%22%2C %22timestamp%22%3A %222014-12-03 17%3A04%3A36%22%2C %22raw_node%22%3A %22634d71461df82f2095f18955cf967b606cb25f84%22%2C %22parents%22%3A %5B%22d94b7645874e%22%5D%2C %22branch%22%3A %22unknownbranch%22%2C %22message%22%3A %22hook test 3%5Cn%22%2C %22revision%22%3A null%2C %22size%22%3A -1%7D%5D%2C %22canon_url%22%3A %22https%3A%2F%2Fbitbucket.org%22%2C %22user%22%3A %22tobru%22%7D'
    assert last_response.ok?
    assert last_response.body.must_match "webhook received"
  end
  # payload has a known repository and branch without command configured
  it 'should output 500 - no command configuration found' do
    authorize user, pass
    post '/payload/bitbucket', 'payload' => '%7B%22repository%22%3A %7B%22website%22%3A %22%22%2C %22fork%22%3A false%2C %22name%22%3A %22puppet-control%22%2C %22scm%22%3A %22git%22%2C %22owner%22%3A %22theowner%22%2C %22absolute_url%22%3A %22%2Ftheowner%2Fpuppet-control%2F%22%2C %22slug%22%3A %22puppet-control%22%2C %22is_private%22%3A true%7D%2C %22truncated%22%3A false%2C %22commits%22%3A %5B%7B%22node%22%3A %22634d71461df8%22%2C %22files%22%3A %5B%7B%22type%22%3A %22modified%22%2C %22file%22%3A %22hooktest.txt%22%7D%5D%2C %22raw_author%22%3A %22Tobias Brunner %3Ctobias%40domain.com%3E%22%2C %22utctimestamp%22%3A %222014-12-03 16%3A04%3A36%2B00%3A00%22%2C %22author%22%3A %22tobru%22%2C %22timestamp%22%3A %222014-12-03 17%3A04%3A36%22%2C %22raw_node%22%3A %22634d71461df82f2095f18955cf967b606cb25f84%22%2C %22parents%22%3A %5B%22d94b7645874e%22%5D%2C %22branch%22%3A %22nocommandbranch%22%2C %22message%22%3A %22hook test 3%5Cn%22%2C %22revision%22%3A null%2C %22size%22%3A -1%7D%5D%2C %22canon_url%22%3A %22https%3A%2F%2Fbitbucket.org%22%2C %22user%22%3A %22tobru%22%7D'
    assert_equal 500, last_response.status
    assert last_response.body.must_match "no command configuration found"
  end
  # payload has a known repository and branch without any configuration
  it 'should output 500 - branch configuration is empty' do
    authorize user, pass
    post '/payload/bitbucket', 'payload' => '%7B%22repository%22%3A %7B%22website%22%3A %22%22%2C %22fork%22%3A false%2C %22name%22%3A %22puppet-control%22%2C %22scm%22%3A %22git%22%2C %22owner%22%3A %22theowner%22%2C %22absolute_url%22%3A %22%2Ftheowner%2Fpuppet-control%2F%22%2C %22slug%22%3A %22puppet-control%22%2C %22is_private%22%3A true%7D%2C %22truncated%22%3A false%2C %22commits%22%3A %5B%7B%22node%22%3A %22634d71461df8%22%2C %22files%22%3A %5B%7B%22type%22%3A %22modified%22%2C %22file%22%3A %22hooktest.txt%22%7D%5D%2C %22raw_author%22%3A %22Tobias Brunner %3Ctobias%40domain.com%3E%22%2C %22utctimestamp%22%3A %222014-12-03 16%3A04%3A36%2B00%3A00%22%2C %22author%22%3A %22tobru%22%2C %22timestamp%22%3A %222014-12-03 17%3A04%3A36%22%2C %22raw_node%22%3A %22634d71461df82f2095f18955cf967b606cb25f84%22%2C %22parents%22%3A %5B%22d94b7645874e%22%5D%2C %22branch%22%3A %22emptyconfigbranch%22%2C %22message%22%3A %22hook test 3%5Cn%22%2C %22revision%22%3A null%2C %22size%22%3A -1%7D%5D%2C %22canon_url%22%3A %22https%3A%2F%2Fbitbucket.org%22%2C %22user%22%3A %22tobru%22%7D'
    assert_equal 500, last_response.status
    assert last_response.body.must_match "branch configuration is empty"
  end
  # payload has a known repository and unknown branch and no '_all' configuration
  it 'should output 500 - branch configuration not found: unknownbranch in repo encdata is not configured' do
    authorize user, pass
    post '/payload/bitbucket', 'payload' => '%7B%22repository%22%3A %7B%22website%22%3A %22%22%2C %22fork%22%3A false%2C %22name%22%3A %22encdata%22%2C %22scm%22%3A %22git%22%2C %22owner%22%3A %22theowner%22%2C %22absolute_url%22%3A %22%2Ftheowner%2Fencdata%2F%22%2C %22slug%22%3A %22encdata%22%2C %22is_private%22%3A true%7D%2C %22truncated%22%3A false%2C %22commits%22%3A %5B%7B%22node%22%3A %22634d71461df8%22%2C %22files%22%3A %5B%7B%22type%22%3A %22modified%22%2C %22file%22%3A %22hooktest.txt%22%7D%5D%2C %22raw_author%22%3A %22Tobias Brunner %3Ctobias%40domain.com%3E%22%2C %22utctimestamp%22%3A %222014-12-03 16%3A04%3A36%2B00%3A00%22%2C %22author%22%3A %22tobru%22%2C %22timestamp%22%3A %222014-12-03 17%3A04%3A36%22%2C %22raw_node%22%3A %22634d71461df82f2095f18955cf967b606cb25f84%22%2C %22parents%22%3A %5B%22d94b7645874e%22%5D%2C %22branch%22%3A %22unknownbranch%22%2C %22message%22%3A %22hook test 3%5Cn%22%2C %22revision%22%3A null%2C %22size%22%3A -1%7D%5D%2C %22canon_url%22%3A %22https%3A%2F%2Fbitbucket.org%22%2C %22user%22%3A %22tobru%22%7D'
    assert_equal 500, last_response.status
    assert last_response.body.must_match "branch configuration not found: 'unknownbranch' in repo 'encdata' is not configured"
  end
  # payload has a unknown repository
  it 'should output 500 - repository configuration not found: unknownrepo is not configured' do
    authorize user, pass
    post '/payload/bitbucket', 'payload' => '%7B%22repository%22%3A %7B%22website%22%3A %22%22%2C %22fork%22%3A false%2C %22name%22%3A %22unknownrepo%22%2C %22scm%22%3A %22git%22%2C %22owner%22%3A %22theowner%22%2C %22absolute_url%22%3A %22%2Ftheowner%2Fencdata%2F%22%2C %22slug%22%3A %22encdata%22%2C %22is_private%22%3A true%7D%2C %22truncated%22%3A false%2C %22commits%22%3A %5B%7B%22node%22%3A %22634d71461df8%22%2C %22files%22%3A %5B%7B%22type%22%3A %22modified%22%2C %22file%22%3A %22hooktest.txt%22%7D%5D%2C %22raw_author%22%3A %22Tobias Brunner %3Ctobias%40domain.com%3E%22%2C %22utctimestamp%22%3A %222014-12-03 16%3A04%3A36%2B00%3A00%22%2C %22author%22%3A %22tobru%22%2C %22timestamp%22%3A %222014-12-03 17%3A04%3A36%22%2C %22raw_node%22%3A %22634d71461df82f2095f18955cf967b606cb25f84%22%2C %22parents%22%3A %5B%22d94b7645874e%22%5D%2C %22branch%22%3A %22unknownbranch%22%2C %22message%22%3A %22hook test 3%5Cn%22%2C %22revision%22%3A null%2C %22size%22%3A -1%7D%5D%2C %22canon_url%22%3A %22https%3A%2F%2Fbitbucket.org%22%2C %22user%22%3A %22tobru%22%7D'
    assert_equal 500, last_response.status
    assert last_response.body.must_match "repository configuration not found: 'unknownrepo' is not configured"
  end
end
