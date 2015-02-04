require 'webhookd/logging'
module Webhookd
  class ParsePayload

    include Logging

    def initialize(payload)
      @payload = payload
    end

    def parse
      require 'json'
      logger.debug 'parsing payload type bitbucket'

      prepared = URI.unescape(@payload.gsub("payload=","").gsub("+"," "))
      json_parsed = JSON.parse(URI.unescape(prepared))
      logger.debug "raw received data: #{json_parsed}"

      # loop through commits to find the branch
      branch_name = '_notfound'
      author_name = '_notfound'
      json_parsed['commits'].each do |commit|
        if commit['branch']
          branch_name = commit['branch']
          author_name = commit['author']
          break
        end
      end

      data = Hash.new
      data[:type] = 'vcs'
      data[:source] = 'bitbucket'
      data[:repo_name] = json_parsed['repository']['name']
      data[:branch_name] = branch_name
      data[:author_name] = author_name

      logger.debug "parsed from the bitbucket data: #{data}"

      # return the hash
      data
    end
  end
end
