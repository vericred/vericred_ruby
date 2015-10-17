module Vericred
  module Relationships
    class BelongsTo < Relationships::Base
      def foreign_key
        "#{root_name.singularize}_id"
      end

      def singular?
        true
      end
    end
  end
end