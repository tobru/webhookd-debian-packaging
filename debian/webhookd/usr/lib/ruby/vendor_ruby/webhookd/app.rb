require 'sinatra/base'
require 'erb'
require 'thin'
require 'webhookd/version'
require 'webhookd/command_runner'
require 'webhookd/logging'
require 'webhookd/configuration'

module Webhookd
  class App < Sinatra::Base
    configuration_file = ENV["CONFIG_FILE"] || 'etc/example.yml'
    Configuration.load!(configuration_file)
    include Logging

    # Sinatra configuration
    set :show_exceptions, false
    set server: 'thin', connections: [], history_file: 'history.yml'

    # helpers
    helpers do
      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Webhookd authentication"'
        halt 401, "Not authorized\n"
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        user = Configuration.settings[:global][:username]
        password = Configuration.settings[:global][:password]
        @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [user,password]
      end
    end

    # error handling
    not_found do
      "Route not found. Do you know what you want to do?\n"
    end

    error do |err|
      "I'm so sorry, there was an application error: #{err}\n"
    end

    ### Sinatra routes
    # we don't have anything to show
    get '/' do
      protected!
      logger.info "incoming request from #{request.ip} for GET /"
      "I'm running. Nice, isn't it?\n"
    end

    post '/payload/:payloadtype' do
      protected!
      logger.info "incoming request from #{request.ip} for payload type #{params[:payloadtype]}"

      begin
        logger.debug "try to load webhookd/payloadtype/#{params[:payloadtype]}.rb"
        load "webhookd/payloadtype/#{params[:payloadtype]}.rb"
      rescue LoadError
        logger.error "file not found: webhookd/payloadtype/#{params[:payloadtype]}.rb"
        halt 400, "Payload type unknown\n"
      end

      parser = ParsePayload.new(request.body.read)
      parsed_data = parser.parse

      # see if the payloadtype is known
      if Configuration.settings.has_key?(parsed_data[:type].to_sym)
        case parsed_data[:type]
          when 'vcs'
            # reload configuration
            Configuration.load!(configuration_file)

            branch_name = parsed_data[:branch_name]
            repo_name = parsed_data[:repo_name]
            repo_config = nil
            branch_config = nil
            command = nil

            # is the repository configured?
            if Configuration.settings[:vcs].has_key?(repo_name.to_sym)
              logger.debug "repository configuration found"
              repo_config = Configuration.settings[:vcs][repo_name.to_sym]
            elsif Configuration.settings[:vcs].has_key?(:_all)
              logger.debug "repository configuration not found, but there is an '_all' rule"
              repo_config = Configuration.settings[:vcs][:_all]
            else
              error_msg = "repository configuration not found: '#{repo_name}' is not configured\n"
              logger.fatal error_msg
              halt 500, "#{error_msg}\n"
            end

            # check if there is a repo_config available
            if repo_config
              # is the branch explicitely configured?
              if repo_config.has_key?(branch_name.to_sym)
                logger.debug "branch configuration found"
                branch_config = repo_config[branch_name.to_sym]
              elsif repo_config.has_key?(:_all)
                logger.debug "branch configuration not found, but there is an '_all' rule"
                branch_config = repo_config[:_all]
              else
                error_msg = "branch configuration not found: '#{branch_name}' in repo '#{repo_name}' is not configured\n"
                logger.fatal error_msg
                halt 500, "#{error_msg}\n"
              end
            end

            # check if there is branch configuration data available
            if branch_config
              # is there a command configured?
              if branch_config[:command]
                command = branch_config[:command]
              else
                error_msg = "no command configuration found\n"
                logger.fatal error_msg
                halt 500, error_msg
              end
            else
              error_msg = "branch configuration is empty\n"
              logger.fatal error_msg
              halt 500, error_msg
            end

            # check for a command to run and then run it
            if command
              parsed_command = ERB.new(command).result(binding)
              command_runner = Commandrunner.new(parsed_command)
              command_runner.run
            end
          # we don't know the type of this known payload
          else
            error_msg = "webhook payload type #{parsed_data[:type]} unknown"
            logger.fatal error_msg
            halt 500, "#{error_msg}\n"
        end
      # this type of payload is not configured
      else
        error_msg = "webhook payload of type #{parsed_data[:type]} not configured"
        logger.info error_msg
        halt 500, "#{error_msg}\n"
      end

      logger.debug "using configuration file #{configuration_file}"
      # output to the requester
      "webhook received\n"
    end
  end
end
