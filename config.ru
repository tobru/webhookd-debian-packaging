begin
  require 'webhookd'
rescue LoadError => e
  require 'rubygems'
  require 'bundler'
  path = File.expand_path '../../lib', __FILE__
  $:.unshift(path) if File.directory?(path) && !$:.include?(path)
  Bundler.setup
  require 'webhookd'
end

run Webhookd::App
