# -*- encoding: utf-8 -*-
# stub: webhookd 0.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "webhookd"
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Tobias Brunner"]
  s.date = "2015-01-31"
  s.description = "This app is a flexible, configurable universal webhook receiver, built with sinatra. It can receive a webhook, parse its payload and take action according to the configuration."
  s.email = ["tobias@tobru.ch"]
  s.executables = ["webhookd"]
  s.files = [".gitignore", "CHANGELOG.md", "Gemfile", "LICENSE", "README.md", "Rakefile", "bin/webhookd", "config.ru", "etc/example.yml", "etc/example.yml.dist", "lib/webhookd.rb", "lib/webhookd/app.rb", "lib/webhookd/cli.rb", "lib/webhookd/command_runner.rb", "lib/webhookd/configuration.rb", "lib/webhookd/logging.rb", "lib/webhookd/payloadtype/bitbucket.rb", "lib/webhookd/payloadtype/gitlab.rb", "lib/webhookd/version.rb", "scripts/test/curl-bitbucket-explicit-repo-and-branch.sh", "scripts/test/curl-bitbucket-explicit-repo-wrong-branch.sh", "scripts/test/curl-bitbucket-nocommand.sh", "scripts/test/curl-bitbucket-unknown-repo.sh", "scripts/test/curl-gitlab-unknown-repo.sh", "scripts/webhookd.default", "scripts/webhookd.init", "test/helper.rb", "test/test_basics.rb", "test/test_bitbucket.rb", "webhookd.gemspec"]
  s.homepage = "https://github.com/tobru/webhookd"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Flexible, configurable universal webhook receiver"
  s.test_files = ["test/helper.rb", "test/test_basics.rb", "test/test_bitbucket.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rack-test>, [">= 0.6.0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 1.4.5", "~> 1.4"])
      s.add_runtime_dependency(%q<thor>, [">= 0.18.1", "~> 0.18"])
      s.add_runtime_dependency(%q<thin>, [">= 1.6.3", "~> 1.6"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rack-test>, [">= 0.6.0"])
      s.add_dependency(%q<sinatra>, [">= 1.4.5", "~> 1.4"])
      s.add_dependency(%q<thor>, [">= 0.18.1", "~> 0.18"])
      s.add_dependency(%q<thin>, [">= 1.6.3", "~> 1.6"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rack-test>, [">= 0.6.0"])
    s.add_dependency(%q<sinatra>, [">= 1.4.5", "~> 1.4"])
    s.add_dependency(%q<thor>, [">= 0.18.1", "~> 0.18"])
    s.add_dependency(%q<thin>, [">= 1.6.3", "~> 1.6"])
  end
end
