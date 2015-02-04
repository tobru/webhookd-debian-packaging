require 'thor'

module Webhookd
  class CLI < Thor
    include Thor::Actions

    attr_reader :name

    desc "start", "Starts the webhookd server"
    method_option :config_file, :desc => "Path to the configuration file"
    def start(*args)
      port_option = args.include?('-p') ? '' : ' -p 8088'
      args = args.join(' ')
      command = "thin -R #{get_rackup_config} start#{port_option} #{args}"
      command.prepend "export CONFIG_FILE=#{options[:config_file]}; " if options[:config_file]
      begin
        run_command(command)
      rescue SystemExit, Interrupt
        puts "Program interrupted"
        exit
      end
    end

    desc "stop", "Stops the thin server"
    def stop
      command = "thin -R #{get_rackup_config} stop"
      run_command(command)
    end

    # map some commands
    map 's' => :start

    private

    def get_rackup_config
      begin
        spec = Gem::Specification.find_by_name('webhookd')
        "#{spec.gem_dir}/config.ru"
      rescue Gem::LoadError
        if File.exist?('/etc/webhookd/config.ru')
          '/etc/webhookd/config.ru'
        else
          './config.ru'
        end
      end
    end

    def run_command(command)
      system(command)
    end

    def require_file(file)
      require file
    end
  end
end

