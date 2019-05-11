require 'net/https'

class IgdbQuery
  include ActiveModel::Validations
  attr_reader :query, :offset, :results, :last_input
  validates :query, presence: true

  FIELDS = "f name,first_release_date,status,parent_game,cover.image_id,platforms.name"
  RESULT_LIMIT = 50
  OFFSET_LIMIT = 150
  LIST_LIMIT = 10

  def initialize(obj, offset = 0)
    @last_input = obj

    @query = obj["inquiry"]
    @offset = offset
    @fixed_query, @type = analyze_query(@query)

    @platforms = obj.slice(:console,
                           :arcade,
                           :portable,
                           :pc,
                           :linux,
                           :mac,
                           :mobile,
                           :computer,
                           :other)

    @platforms.each { |k, v| @platforms[k] = !(v.to_i.zero?) }

    @erotic = !(obj[:erotic].to_i.zero?)
    @only_released = !(obj[:only_released].to_i.zero?)



    @where, @search , @sort  = '', '', ''
    @results = []

    puts 'IGDB-> INITIALIZED:'
    puts "query: #{@query}"
    puts "fixed_query: #{@fixed_query}"
    puts "type: #{@type}"
    puts "platforms: #{@platforms}"
    puts "erotic: #{@erotic}"
    puts "only_released: #{@only_released}"
  end

  def search
    prepare_platforms
    prepare_where
    prepare_search
    prepare_sort
    request(@offset)
  end

  def prepare_platforms
    unless @platforms.values.all?
      if calculate_rm_cost > LIST_LIMIT
        puts "IGDB-> ADDING PLATFORMS"
        add_platforms
      else
        puts "IGDB-> REMOVING PLATFORMS"
        remove_platforms
      end
    end
  end

  def calculate_rm_cost
    cost = { "console" => 4,
              "arcade" => 0,
              "portable" => 0,
              "pc" => 2,
              "linux" => 2,
              "mac" => 1,
              "mobile" => 3,
              "computer" => 0,
              "other" => 3 }

    result = 0

    @platforms.each { |k, _v| result += cost[k] unless @platforms[k] }

    puts "IGDB-> RM_COST: #{result}"
    result
  end

  def add_platforms
    # @platforms array should have 9 keys:
    # console
    # arcade
    # portable
    # pc
    # linux
    # mac
    # mobile
    # computer
    # other
    #
    # IGDB Platform Categories:
    # console 1
    # arcade  2
    # platform  3 (web browser, eshop e.t.c)
    # operating_system  4
    # portable_console  5
    # computer  6 (zx spectrum, apple II e.t.c)

    yes_categories = []
    yes_platforms = []
    # Add big consoles (with Nintendo eShop, XBLA, PSN, Virtual Console):
    if @platforms[:console]
       yes_categories.push 1
       yes_platforms.push 160, 36, 45, 47
    end
    # Add arcade:
    yes_categories.push 2 if @platforms[:arcade]
    # Add portable consoles (with Ngage):
    yes_categories.push 5 if @platforms[:portable]
    # Add PC (with PC DOS):
    yes_platforms.push 6, 13 if @platforms[:pc]
    # Add Linux (with SteamOS):
    yes_platforms.push 3, 92 if @platforms[:linux]
    # Add Mac:
    yes_platforms.push 14 if @platforms[:mac]
    # Add mobile (iOs, BlackBerry Os, Android):
    yes_platforms.push 39, 73, 34 if @platforms[:mobile]
    # Add old computers:
    yes_categories.push 6 if @platforms[:computer]
    # Add other (Amazon Fire TV, Web browser, OnLive Game System):
    yes_platforms.push 132, 82, 113 if @platforms[:other]

    unless yes_categories.empty?
      @where.blank? ? @where += 'w ' : @where += '| '
      @where += "(platforms.category = (#{yes_categories.join(',')})) "
    end

    unless yes_platforms.empty?
      @where.blank? ? @where += 'w ' : @where += '| '
      @where += "(platforms = (#{yes_platforms.join(',')})) "
    end
  end

  def remove_platforms
    # @platforms array should have 9 keys:
    # console
    # arcade
    # portable
    # pc
    # linux
    # mac
    # mobile
    # computer
    # other
    #
    # IGDB Platform Categories:
    # console 1
    # arcade  2
    # platform  3 (web browser, eshop e.t.c)
    # operating_system  4
    # portable_console  5
    # computer  6 (zx spectrum, apple II e.t.c)

    no_categories = []
    no_platforms = []
    # Remove big consoles (with Nintendo eShop, XBLA, PSN, Virtual Console):
    unless @platforms[:console]
       no_categories.push 1
       no_platforms.push 160, 36, 45, 47
    end
    # Remove arcade:
    no_categories.push 2 unless @platforms[:arcade]
    # Remove portable consoles (with Ngage):
    no_categories.push 5 unless @platforms[:portable]
    # Remove PC (with PC DOS):
    no_platforms.push 6, 13 unless @platforms[:pc]
    # Remove Linux (with SteamOS):
    no_platforms.push 3, 92 unless @platforms[:linux]
    # Remove Mac:
    no_platforms.push 14 unless @platforms[:mac]
    # Remove mobile (iOs, BlackBerry Os, Android):
    no_platforms.push 39, 73, 34 unless @platforms[:mobile]
    # Remove old computers:
    no_categories.push 6 unless @platforms[:computer]
    # Remove other (Amazon Fire TV, Web browser, OnLive Game System):
    no_platforms.push 132, 82, 113 unless @platforms[:other]

    unless no_categories.empty?
      @where.blank? ? @where += 'w ' : @where += '& '
      @where += "(platforms.category != (#{no_categories.join(',')})) "
    end

    unless no_platforms.empty?
      @where.blank? ? @where += 'w ' : @where += '& '
      @where += "(platforms != (#{no_platforms.join(',')})) "
    end
  end

  def prepare_where

    if @where.present? && @type != :search
      @where += '& '
    elsif @type != :search
      @where += 'w '
    end

    case @type
    when :prefix then @where += "(name ~ *#{@fixed_query.inspect})"
    when :postfix then @where += "(name ~ #{@fixed_query.inspect}*)"
    when :infix then @where += "(name ~ *#{@fixed_query.inspect}*)"
    end

    @where += "; " if @where.present?
  end

  def prepare_search
      @search = "search #{@fixed_query.inspect}; " if @type == :search
  end

  def prepare_sort
      @sort = "sort popularity desc; " if @type != :search
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
    elsif @results.count == RESULT_LIMIT && @offset == OFFSET_LIMIT
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
        type = :prefix
      elsif !fixed_query.match(/\A[^*].*[*]\z/).nil?
        fixed_query.delete_suffix!("*")
        type = :postfix
      elsif !fixed_query.match(/\A[*].*[*]\z/).nil?
        fixed_query.delete_prefix!("*").delete_suffix!("*")
        type = :infix
      end
      return [fixed_query, type]
    end

    def request(offset)
      http = Net::HTTP.new('api-v3.igdb.com', 80)
      request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/games'),
       { 'user-key' => ENV['IGDB_KEY'] })

      request.body = FIELDS + '; ' + @search + @where + @sort + "limit #{RESULT_LIMIT}; " + "offset #{offset};"

      puts 'IGDB-> REQUEST:'
      puts request.body

      @results = JSON.parse http.request(request).body

      puts 'IGDB-> RECEIVED RESULTS:'
      puts @results
      puts '=' * 100
    end
end
