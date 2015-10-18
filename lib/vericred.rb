require 'active_support'
require 'active_support/core_ext'
require 'celluloid/current'
require 'httpclient'
require 'json'
require 'ostruct'

require 'vericred/version'
require 'vericred/api_resource'
require 'vericred/api_resource/relationships/base'
require 'vericred/api_resource/relationships/belongs_to'
require 'vericred/api_resource/relationships/has_many'
require 'vericred/errors'
require 'vericred/connection'
require 'vericred/resources'

module Vericred
  def self.config
    @config ||= OpenStruct.new
  end

  def self.configure(&block)
    yield(self.config)
  end
end
