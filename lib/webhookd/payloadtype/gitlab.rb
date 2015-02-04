require 'webhookd/logging'
module Webhookd
  class ParsePayload

    include Logging

    def initialize(payload)
      @payload = payload
    end

    def parse
      require 'json'
      logger.debug 'parsing payload type gitlab'

      json_parsed = JSON.parse(@payload)
      logger.debug "raw received data: #{json_parsed}"

      data = Hash.new
      data[:type] = 'vcs'
      data[:source] = 'gitlab'
      data[:repo_name] = json_parsed['repository']['name']
      data[:branch_name] = json_parsed['ref'].split("/")[2]
      data[:author_name] = json_parsed['user_name']

      logger.info "parsed from the gitlab data: #{data}"

      # return the hash
      data
    end
  end
end
