module Vericred
  class ApiResource
    class_attribute :connection
    class_attribute :logger
    class_attribute :relationships

    BASE_URL = "https://api.vericred.com"

    self.relationships = { has_many: {}, belongs_to: {} }
    self.logger = Logger.new(STDOUT)

    def self.belongs_to(type)
      self.relationships[:belongs_to][type] =
        Vericred::Relationships::BelongsTo.new(self, type)
    end

    def self.connection
      @connection ||= Vericred::Connection.pool(size: 5)
    end

    def self.find(id)
      data = make_request(:get, uri(id), {}, headers)
      new(data[root_name] || {}, data)
    end

    def self.future
      FutureProxy.new(self)
    end

    def self.has_many(type)
      self.relationships[:has_many][type] =
        Vericred::Relationships::HasMany.new(self, type)
    end

    def self.uri(id = nil)
      "/#{root_name.pluralize}".tap do |ret|
        ret << "/#{id}" if id.present?
      end
    end

    def self.headers
      {
        'Vericred-Api-Key' => Vericred.config.api_key
      }
    end

    def self.root_name
      self.to_s.split("::").last.gsub(/([^^])([A-Z])/,'\1_\2').downcase
    end

    def self.search(query = {})
      data = make_request(:get, uri, query, headers)
      (data[root_name.pluralize] || []).map { |row| new(row, data) }
    end

    def initialize(attrs, full_data = {})
      parse_relationships(attrs, full_data)
      @data = OpenStruct.new(attrs)
    end

    private

    def self.handle_response(response)
      case response.status
      when 200..299 then JSON.parse(response.content)
      when 401 then fail Vericred::UnauthenticatedError, response
      when 403 then fail Vericred::UnauthorizedError, response
      when 422 then fail Vericred::UnprocessableEntityError, response
      else
        fail Vericred::UnknownError, response
      end
    end

    def self.make_request(verb, uri, *args)
      logger.info { "#{verb.to_s.upcase} #{uri} with #{args}"}
      response = nil
      ActiveSupport::Notifications
        .instrument "vericred.http_request", opts: [verb, uri, *args] do
          response = connection.send(verb, "#{BASE_URL}#{uri}", *args)
        end
      handle_response(response)
    end

    def method_missing(m, *args, &block)
      return @data.send(m, *args, &block) if @data.respond_to?(m)
      super
    end

    def parse_plural_relationship(relationship, attrs, full_data)
      attrs[relationship.root_name] =
        full_data[relationship.root_name]
          .select { |row| attrs[relationship.foreign_key].include?(row['id'])}
          .map { |row| OpenStruct.new(row) }
    end

    def parse_singular_relationship(relationship, attrs, full_data)
      record = full_data[relationship.root_name]
                 .find { |row| row['id'] == attrs[relationship.foreign_key] }
      attrs[relationship.root_name.singularize] =
        record ? OpenStruct.new(record) : nil
    end

    def parse_relationships(attrs, full_data)
      relationships.values.map(&:values).flatten.each do |relationship|
        next if full_data[relationship.root_name].blank?
        relationship.singular? ?
          parse_singular_relationship(relationship, attrs, full_data) :
          parse_plural_relationship(relationship, attrs, full_data)
      end
    end
  end
end