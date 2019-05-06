require 'net/https'

class IgdbQuery
  include ActiveModel::Validations
  attr_reader :query, :offset, :results
  validates :query, presence: true

  RESULT_LIMIT = 50
  OFFSET_LIMIT = 150

  def initialize(query = "", offset = 0)
    @query, @offset = query, offset
    @results = []
    puts "Initialized with query #{query} and offset #{offset}"
  end

  def search
    data = analyze_query(@query)
    request(data[:query], data[:type])
  end

  def is_more?
    if @results.count == RESULT_LIMIT && @offset < OFFSET_LIMIT
      return true
    else
      return false
    end
 end

  def status_id
    if @results.empty?
      return 0 # Before first search
    elsif @results.count == RESULT_LIMIT && @offset < OFFSET_LIMIT
      return 1 # There are more results and limit has not been reached
    elsif @results.count == RESULT_LIMIT && @offset = OFFSET_LIMIT
      return 2 # There are more results but limit has been reached
    else
      return 3 # Fully finished search
    end
  end

  private
    def analyze_query(query)
      fixed_query = query.strip
      fixed_query.gsub!(/\s\s+/, " ")
      type = :search
      if !fixed_query.match(/\A[*].*[^*]\z/).nil?
        fixed_query.delete_prefix!("*")
        type = :where_prefix
      elsif !fixed_query.match(/\A[^*].*[*]\z/).nil?
        fixed_query.delete_suffix!("*")
        type = :where_postfix
      elsif !fixed_query.match(/\A[*].*[*]\z/).nil?
        fixed_query.delete_prefix!("*").delete_suffix!("*")
        type = :where_infix
      end
      return { :query => fixed_query, :type => type }
    end

    def request(query = @query, type = :search, offset = @offset)
      http = Net::HTTP.new('api-v3.igdb.com', 80)
      request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/games'),
       { 'user-key' => ENV['IGDB_KEY'] })
      # add status = 0 (onyl released games)
      if type == :search
        request.body = "fields name, first_release_date;
                        search #{query.inspect};
                        limit #{RESULT_LIMIT};
                        offset #{offset};"
      elsif type == :where_prefix
        request.body = "fields name, first_release_date;
                        where name ~ *#{query.inspect};
                        sort popularity desc;
                        limit #{RESULT_LIMIT};
                        offset #{offset};"
      elsif type == :where_postfix
        request.body = "fields name, first_release_date;
                        where name ~ #{query.inspect}*;
                        sort popularity desc;
                        limit #{RESULT_LIMIT};
                        offset #{offset};"
      elsif type == :where_infix
        request.body = "fields name, first_release_date;
                        where name ~ *#{query.inspect}*;
                        sort popularity desc;
                        limit #{RESULT_LIMIT};
                        offset #{offset};"
      end
      @results = JSON.parse http.request(request).body
    end
end
