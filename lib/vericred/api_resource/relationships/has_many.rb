module Vericred
  module Relationships
    class HasMany < Relationships::Base
      def foreign_key
        "#{root_name.singularize}_ids"
      end

      def singular?
        false
      end
    end
  end
end