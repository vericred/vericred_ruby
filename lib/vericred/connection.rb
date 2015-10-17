require 'celluloid'

module Vericred
  class Connection
    def initialize
      @connection = HTTPClient.new
    end

    delegate :get, :post, :put, :delete, to: :connection

    private

    attr_reader :connection
  end
end