require 'webhookd/logging'
module Webhookd
  class ParsePayload

    include Logging

    def initialize(payload)
      @payload = payload
    end

    def parse
      logger.debug 'parsing payload type debug'
      logger.debug "raw received data: #{@payload}"

      data = Hash.new
      data[:type] = 'debug'

      data
    end
  end
end
