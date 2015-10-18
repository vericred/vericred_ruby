require 'spec_helper'

describe Vericred::ApiResource do
  Vericred::FooBar = Class.new(Vericred::ApiResource) do
    belongs_to :bar
    has_many :corges
  end
  Vericred::Bar = Class.new(Vericred::ApiResource)
  Vericred::Corge = Class.new(Vericred::ApiResource)

  around do |example|
    begin
      old_connection = Vericred::ApiResource.connection
      example.run
    ensure
      Vericred::ApiResource.connection = old_connection
    end
  end

  context '.uri' do
    it 'returns the normalized URI' do
      expect(Vericred::FooBar.uri).to eql('/foo_bars')
    end

    it 'returns a URI for an ID' do
      expect(Vericred::FooBar.uri(1)).to eql('/foo_bars/1')
    end
  end

  context '.find' do
    it 'makes the correct request' do
      Vericred::ApiResource.connection =
        double(
          :connection,
          get: OpenStruct.new(content: JSON.unparse(foo_bar: {}), status: 200)
        )
      Vericred.config.api_key = '123'

      Vericred::FooBar.find(1)

      expect(Vericred::ApiResource.connection)
        .to have_received(:get)
        .with(
          'https://api.vericred.com/foo_bars/1',
          {},
          { 'Vericred-Api-Key' => '123' }
        )
    end
  end

  context '.search' do
    it 'makes a request to our connection' do
      Vericred::ApiResource.connection =
        double(:connection, get: OpenStruct.new(content: '{}', status: 200))
      Vericred.config.api_key = '123'

      Vericred::FooBar.search(a: 'b', c: ['d', 'e'])

      expect(Vericred::ApiResource.connection)
        .to have_received(:get)
        .with(
          'https://api.vericred.com/foo_bars',
          { a: 'b', c: ['d', 'e'] },
          { 'Vericred-Api-Key' => '123' }
        )
    end

    it 'parses out our responses' do
      Vericred::ApiResource.connection =
        double(
          :connection,
          get: OpenStruct.new(
            status: 200,
            content: JSON.unparse({
              foo_bars: [
                { id: 1, a: 'b' },
                { id: 2, c: 'd' }
              ]
            })
          )
        )
      Vericred.config.api_key = '123'

      foo_bars = Vericred::FooBar.search(a: 'b', c: ['d', 'e'])
      expect(foo_bars.length).to eql 2
      expect(foo_bars[0].a).to eql 'b'
      expect(foo_bars[1].c).to eql 'd'
    end

    context 'with sideloaded data' do
      it 'parses out our responses' do
        Vericred::ApiResource.connection =
          double(
            :connection,
            get: OpenStruct.new(
              status: 200,
              content: JSON.unparse({
                foo_bars: [
                  { id: 1, a: 'b', corge_ids: [1], bar_id: 1 },
                  { id: 2, c: 'd', corge_ids: [2], bar_id: 2 }
                ],
                corges: [
                  { id: 1, name: 'corges' },
                  { id: 2, name: 'corges2' }
                ],
                bars: [
                  { id: 1, name: 'Bar' },
                  { id: 2, name: 'Bar' }
                ]
              })
            )
          )
        Vericred.config.api_key = '123'

        foo_bars = Vericred::FooBar.search(a: 'b', c: ['d', 'e'])
        expect(foo_bars.length).to eql 2

        expect(foo_bars[0].corges[0].id).to eql 1
        expect(foo_bars[1].corges[0].id).to eql 2

        expect(foo_bars[0].bar.id).to eql 1
        expect(foo_bars[1].bar.id).to eql 2
      end
    end

    context 'with a 401' do
      before do
        Vericred::ApiResource.connection =
          double(
            :connection,
            get: OpenStruct.new(
              content: JSON.unparse(errors: { foo: ['bar'] }),
              status: 401
            )
          )
        Vericred.config.api_key = '123'
      end

      it 'raises an error' do
        expect { Vericred::FooBar.search(a: 'b', c: ['d', 'e']) }
          .to raise_error(Vericred::UnauthenticatedError)
      end
    end

    context 'with a 403' do
      before do
        Vericred::ApiResource.connection =
          double(
            :connection,
            get: OpenStruct.new(
              content: JSON.unparse(errors: { foo: ['bar'] }),
              status: 403
            )
          )
        Vericred.config.api_key = '123'
      end

      it 'raises an error' do
        expect { Vericred::FooBar.search(a: 'b', c: ['d', 'e']) }
          .to raise_error(Vericred::UnauthorizedError)
      end
    end

    context 'with a 422' do
      before do
        Vericred::ApiResource.connection =
          double(
            :connection,
            get: OpenStruct.new(
              content: JSON.unparse(errors: { foo: ['bar'] }),
              status: 422
            )
          )
        Vericred.config.api_key = '123'
      end

      it 'raises an error' do
        expect { Vericred::FooBar.search(a: 'b', c: ['d', 'e']) }
          .to raise_error(Vericred::UnprocessableEntityError)
      end
    end

    context 'with a 500' do
      before do
        Vericred::ApiResource.connection =
          double(
            :connection,
            get: OpenStruct.new(
              content: JSON.unparse(errors: { foo: ['bar'] }),
              status: 500
            )
          )
        Vericred.config.api_key = '123'
      end

      it 'raises an error' do
        expect { Vericred::FooBar.search(a: 'b', c: ['d', 'e']) }
          .to raise_error(Vericred::UnknownError)
      end
    end
  end
end