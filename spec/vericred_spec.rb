require 'spec_helper'

describe Vericred do
  it 'has a version number' do
    expect(Vericred::VERSION).not_to be nil
  end

  it 'allows api key configuration' do
    Vericred.configure do |config|
      config.api_key = '12345'
    end
    expect(Vericred.config.api_key).to eql '12345'
  end
end
