module Vericred
  class Connection
    include Celluloid

    def initialize
      @connection = HTTPClient.new
    end

    delegate :get, :post, :put, :delete, to: :connection

    private

    attr_reader :connection
  end
end