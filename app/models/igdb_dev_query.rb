require 'net/https'

class IgdbDevQuery
  include ActiveModel::Validations
  attr_reader :query, :offset, :results, :last_input
  validates :query, presence: true

  FIELDS = "f name, developed.*, developed.platforms.name, developed.cover.image_id"
  RESULT_LIMIT = 50
  OFFSET_LIMIT = 150
  LIST_LIMIT = 10

  def initialize(obj, offset = 0)
    @last_input = obj

    @query = obj['inquiry']
    @offset = offset
    @fixed_query = fix_query(@query)
    @platforms = obj.slice('console',
                           'arcade',
                           'portable',
                           'pc',
                           'linux',
                           'mac',
                           'mobile',
                           'computer',
                           'other')

    @platforms.each { |k, v| @platforms[k] = !(v.to_i.zero?) }

    @categories = obj.slice('dlc',
                           'expansion',
                           'bundle',
                           'standalone')

    @categories.each { |k, v| @categories[k] = !(v.to_i.zero?) }

    @erotic = !(obj['erotic'].to_i.zero?)
    @only_released = !(obj['only_released'].to_i.zero?)
    @where = ''
    @response_size = 0
    @results = []

    puts 'IGDB-> INITIALIZED:'
    puts 'It is IGDB Developer Query'
    puts "query: #{@query}"
    puts "fixed_query: #{@fixed_query}"
    puts "type: #{@type}"
    puts "platforms: #{@platforms}"
    puts "categories: #{@categories}"
    puts "erotic: #{@erotic}"
    puts "only_released: #{@only_released}"
  end

  def search
    define_where
    request(@offset)
  end

  def fix_duplicates(last_result_ids)
    @results.reject! { |game| last_result_ids.include?(game["id"])}
    puts 'IGDB -> Fixed duplicates'
  end

  def is_more?
    if @response_size == RESULT_LIMIT && @offset < OFFSET_LIMIT
      return true
    else
      return false
    end
  end

  def status_id
    if @response_size.zero?
      return 0 # Before first search
    elsif @response_size == RESULT_LIMIT && @offset < OFFSET_LIMIT
      return 1 # There are more results and limit has not been reached
    elsif @response_size == RESULT_LIMIT && @offset == OFFSET_LIMIT
      return 2 # There are more results but limit has been reached
    else
      return 3 # Fully finished search
    end
  end

  private
    def fix_query(query)
      fixed_query = query.strip
      fixed_query.gsub!(/\s\s+/, ' ')
      return fixed_query
    end

    def define_where
      @where += "w ((name ~ *#{@fixed_query.inspect}*) | (slug ~ *#{@fixed_query.inspect}*) & developed != null);"
      puts 'IGDB -> Defined where'
    end

    def request(offset)
      http = Net::HTTP.new('api-v3.igdb.com', 80)
      request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/companies'),
       { 'user-key' => ENV['IGDB_KEY'] })

      request.body = FIELDS + '; ' + @where + "limit #{RESULT_LIMIT}; " + "offset #{offset};"

      puts 'IGDB-> REQUEST:'
      puts request.body

      @results = convert_to_games(JSON.parse http.request(request).body)

      @response_size = @results.size

      puts 'IGDB-> RECEIVED RESULTS:'
      puts @results
      puts @results.size
      puts '=' * 100
    end

    def convert_to_games(developers)
      games = []
      developers.each do |developer|
        if developer["developed"]
          developer["developed"].each do |game|
            games.push game if game.class == Hash
          end
        end
      end
      return games
    end
end
