require 'ostruct'

module Vericred
  class Error < RuntimeError
    def initialize(response)
      @response = response
    end

    def errors
      OpenStruct.new(JSON.parse(response.content).try(:[], 'errors') || {})
    end

    def status
      response.status
    end

    private

    attr_reader :response
  end


  TotalNotSupportedError = Class.new(Error) do
    def initialize(klass)
      @klass = klass
    end

    def errors
      OpenStruct.new(
        not_supported: ["#{klass} does not support total"]
      )
    end

    def status
      422
    end
  end

  UnauthenticatedError = Class.new(Error)
  UnauthorizedError = Class.new(Error)
  UnprocessableEntityError = Class.new(Error)
  UnknownError = Class.new(Error)
end