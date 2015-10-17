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

  UnauthenticatedError = Class.new(Error)
  UnauthorizedError = Class.new(Error)
  UnprocessableEntityError = Class.new(Error)
  UnknownError = Class.new(Error)
end