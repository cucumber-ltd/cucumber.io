# frozen_string_literal: true

require 'faraday'
require 'fileutils'
require 'pry-byebug'
require 'webmock/rspec'
require 'nokogiri'

BASE_URL = ENV['BASE_URL'] || 'http://localhost:9001'

RSpec.configure do |config|
  config.before(:suite) do
    dirname = File.dirname('./temp')
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    puts "#{dirname}/."
    # FileUtils.rm_rf("#{dirname}/.", secure: true)
  end
end

def xml(location)
  Nokogiri::XML(location) do |config|
    config.strict.noblanks
  end
end
