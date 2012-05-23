#!/usr/bin/ruby

( puts 'No gem specified, exiting.'; exit 1) unless ARGV[0]

gem = ARGV[0]

require 'rubygems'

def install_gem(gem)
  install_opts = '--no-rdoc --no-ri'
  system("gem install #{gem} #{install_opts}")
  Gem.clear_paths
end

begin
  puts "#{gem} version installed: #{Gem::Specification.find_by_name(gem).version}."
rescue Gem::LoadError
  install_gem(gem)
rescue
  install_gem(gem) unless Gem.available?(gem)
end