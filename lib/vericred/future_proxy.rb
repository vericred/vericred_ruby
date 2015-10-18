module Vericred
  class FutureProxy
    def initialize(object)
      @object = object
    end

    private

    attr_reader :object

    def method_missing(m, *args, &block)
      Celluloid::Future.new { object.send(m, *args, &block) }
    end
  end
end