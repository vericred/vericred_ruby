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
      @connection ||= Vericred::Connection.new
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

    def initialize(attributes, full_data = {})
      parse_relationships(attributes, full_data)
      @data = OpenStruct.new(attributes)
    end

    private

    def self.make_request(verb, uri, *args)
      logger.info { "#{verb.to_s.upcase} #{uri} with #{args}"}
      response = connection.send(verb, "#{BASE_URL}#{uri}", *args)
      case response.status
      when 200..299 then JSON.parse(response.content)
      when 401 then fail Vericred::UnauthenticatedError, response
      when 403 then fail Vericred::UnauthorizedError, response
      when 422 then fail Vericred::UnprocessableEntityError, response
      else
        fail Vericred::UnknownError, response
      end
    end

    def method_missing(m, *args, &block)
      return @data.send(m, *args, &block) if @data.respond_to?(m)
      super
    end

    def parse_relationships(attributes, full_data)
      relationships.values.map(&:values).flatten.each do |relationship|
        next if full_data[relationship.root_name].blank?
        if relationship.singular?
          record = full_data[relationship.root_name].find do |row|
                    row['id'] == attributes[relationship.foreign_key]
                   end
          attributes[relationship.root_name.singularize] =
            record ? OpenStruct.new(record) : nil
        else
          attributes[relationship.root_name] =
            full_data[relationship.root_name]
              .select { |row| attributes[relationship.foreign_key].include?(row['id'])}
              .map { |row| OpenStruct.new(row) }
        end
      end
    end
  end
end