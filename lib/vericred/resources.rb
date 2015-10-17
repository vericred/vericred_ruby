module Vericred
  class County < Vericred::ApiResource
  end

  class Plan < Vericred::ApiResource
  end

  class Provider < Vericred::ApiResource
    belongs_to :state
  end

  class State < Vericred::ApiResource
  end

  class ZipCode < Vericred::ApiResource
  end

  class ZipCounty < Vericred::ApiResource
    belongs_to :county
    belongs_to :zip_code
  end
end