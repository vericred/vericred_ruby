module Vericred
  module Relationships
    class Base
      def initialize(owner_klass, type)
        @owner_klass = owner_klass
        @type = type
      end

      def owned_klass
        @owned_klass ||= Vericred.const_get(type.to_s.classify)
      end

      def plural?
        !singular?
      end

      def singular?
        fail NotImplementedError, 'must implement #singular?'
      end

      def root_name
        owned_klass.root_name.pluralize
      end

      private

      attr_reader :type
    end
  end
end