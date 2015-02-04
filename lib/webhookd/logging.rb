require 'logger'
require 'webhookd/configuration'

module Logging
  class MultiIO
    def initialize(*targets)
       @targets = targets
    end

    def write(*args)
      @targets.each {|t| t.write(*args)}
    end

    def close
      @targets.each(&:close)
    end
  end

  # This is the magical bit that gets mixed into your classes
  def logger
    @logger ||= Logging.logger_for(self.class.name)
  end

  # Use a hash class-ivar to cache a unique Logger per class:
  @loggers = {}

  class << self
    def logger_for(classname)
      @loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logfile = File.open(Configuration.settings[:global][:logfile], 'a')
      logfile.sync = true
      logger = Logger.new MultiIO.new(STDOUT, logfile)
      case Configuration.settings[:global][:loglevel]
        when 'debug' then logger.level = Logger::DEBUG
        when 'info' then logger.level = Logger::INFO
        when 'warn' then logger.level = Logger::WARN
        when 'error' then logger.level = Logger::ERROR
        when 'fatal' then logger.level = Logger::FATAL
        when 'unknown' then logger.level = Logger::UNKNOWN
        else logger.level = Logger::DEBUG
      end
      logger.progname = classname
      logger
    end
  end
end
