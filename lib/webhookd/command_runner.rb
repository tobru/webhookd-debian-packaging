require 'open3'
require 'webhookd/logging'

module Webhookd
  class Commandrunner

    include Logging

    def initialize(command)
      @command = command
    end

    def run
      begin
        logger.info "Running command: #{@command}"
        Open3::popen2e(@command) { |stdin, stdout_err, wait_thr|
          while line = stdout_err.gets
            logger.info("STDOUTERR: #{line.strip}")
          end
          if wait_thr.value.success?
            logger.info "command successfully finished"
            return true
          else
            logger.error "command failed"
            return false
          end
        }
      rescue Exception => e
        logger.fatal "command running completely failed: #{e.message}"
      end
    end
  end
end
