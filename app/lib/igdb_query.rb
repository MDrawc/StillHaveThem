require 'net/https'

class IgdbQuery
  extend ActiveModel::Naming
  attr_reader :errors, :input, :offset, :results, :last_input

  FIELDS_GAMES = ["name",
  "first_release_date",
  "screenshots.image_id",
  "summary",
  "status",
  "category",
  "cover.image_id",
  "cover.width",
  "cover.height",
  "involved_companies.company.name",
  "involved_companies.developer",
  "platforms.name"].join(',')

  FIELDS_DEV = ["name",
  "developed.name",
  "developed.first_release_date",
  "developed.screenshots.image_id",
  "developed.summary",
  "developed.status",
  "developed.category",
  "developed.cover.image_id",
  "developed.cover.width",
  "developed.cover.height",
  "developed.platforms.category",
  "developed.platforms.name"].join(',')

  FIELDS_CHAR = ["name",
  "games.name",
  "games.first_release_date",
  "games.screenshots.image_id",
  "games.summary",
  "games.status",
  "games.category",
  "games.cover.image_id",
  "games.cover.width",
  "games.cover.height",
  "games.involved_companies.company.name",
  "games.involved_companies.developer",
  "games.platforms.name",
  "games.platforms.category"].join(',')

  PLATFORMS = { "console" => { "category" => [1], "platforms" => [160, 36, 45, 47, 56, 165]},
  "arcade" => { "category" => [2], "platforms" => [52]},
  "portable" => { "category" => [5], "platforms" => []},
  "pc" => { "category" => [], "platforms" => [6, 13, 163, 162]},
  "linux" => { "category" => [], "platforms" => [3, 92]},
  "mac" => { "category" => [], "platforms" => [14]},
  "mobile" => { "category" => [], "platforms" => [39, 73, 34, 55]},
  "computer" => { "category" => [6], "platforms" => []},
  "other" => { "category" => [], "platforms" => [132, 82, 113]}}

  RESULT_LIMIT = 50
  OFFSET_LIMIT = 150
  LIST_LIMIT = 10
  # Limit after which old queries will need to be updated.
  DAYS_LIMIT = 1

  def initialize(obj, offset = 0, query = nil)
    @errors = ActiveModel::Errors.new(self)

    @results = []
    @response_size = 0
    #Store whole input - important for showing more results which is actually
    #sending request again with other offset parameter.
    @last_input = obj

    #There are three query types in SHT:
    #:game - for games
    #:char - for video games characters
    #:dev - for developers
    #Three types and three different endpoints we send request to.
    @query_type = obj['query_type'].to_sym

    @input = obj['inquiry'] #What was written inside search bar
    @offset = offset

    #Clean input out of necessary spaces and define search type.
    #Four search types in SHT are:
    #:search
    #:prefix
    #:postfix
    #:infix
    @fixed_input, @type = analyze_input(@input)
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
    @where, @search , @sort  = '', '', ''

    puts '>> Initialized'
    puts ">> input: #{ @input }"
    puts ">> query type: #{ @query_type }"
    puts ">> fixed_input: #{ @fixed_input }"
    puts ">> type: #{ @type }"
    puts ">> offset: #{ @offset}"
    puts ">> platforms: #{ @platforms }"
    puts ">> categories: #{ @categories }"
    puts ">> erotic: #{ @erotic }"
    puts ">> only_released: #{ @only_released }"
  end

  def prepare_query
    case @query_type
    when :game
      prepare_where
      prepare_search
      prepare_sort
    when :dev
      start_where
      end_where
    when :char then
      start_where
      end_where
      prepare_search
    end
    finish_query
  end

  def recognition_search
  end

  def search
    prepare_query
    unless already_asked?
      initial_search
      save_query
    end
    compose_results if @games_ids
    full_search if @missing_games.present?
  end

  def request(endpoint, body)
    puts '>> REQUEST'
    http = Net::HTTP.new('api-v3.igdb.com', 443)
    http.use_ssl = true
    request = Net::HTTP::Get.new(URI("https://api-v3.igdb.com/#{ endpoint }"),
     { 'user-key' => ENV['IGDB_KEY'] })
    request.body = body
    puts ">> request: #{ request.body }"
    begin
      results = JSON.parse http.request(request).body
      puts ">> received #{ results.size } records"
      puts ">> first result: #{ results.first }"
      puts ">> last result: #{ results.last }"
      rescue JSON::ParserError
        results = []
    end
    return results
  end

  def full_search
    puts '>> FULL SEARCH'
    case @query_type
    when :game then fields = FIELDS_GAMES
    when :dev then fields = FIELDS_DEV
    when :char then fields = FIELDS_CHAR
    end
    results = request(@query[:endpoint], "f #{ fields }; #{ @query[:body] }")
    unless @query_type == :game
      results = convert_to_games(@results, @query_type)
      results = post_filters(results)
    end
    puts ">> first result: #{ results.first }"
    puts ">> results size: #{ @response_size = results.size }"

    prepare_results(results)
  end

  def prepare_results(results)
    puts '>> PREPARE RESULTS'
    new_games = results.select { |g| @missing_games.include?(g['id']) }
    puts '>> converting new games'
    converted = []
    new_games.each do |g|
      c = {}
      c[:igdb_id] = g['id']
      c[:name] = g['name']
      c[:first_release_date] = g['first_release_date']
      c[:summary] = g['summary']
      c[:status] = g['status']
      c[:category] = g['category']
      if g['cover']
        c[:cover] = g['cover']['image_id']
        c[:cover_height] = g['cover']['height']
        c[:cover_width]= g['cover']['width']
      end
      if g['platforms']
        c[:platforms] = platforms = g['platforms'].collect { |platform| platform['id'] }
        c[:platforms_names] = platforms_names = g['platforms'].collect { |platform| platform['name'] }
      end
      c[:developers] = convert_devs(g)
      c[:screenshots] = convert_screenshots(g)
      converted << c
    end
    puts '>> saving new games'
    Agame.create(converted)
    @results += converted
    puts ">> first result: #{ @results.first }"
    puts ">> results size: #{ @results.size }"
  end

  def convert_devs(g)
    involved = g['involved_companies']
    if involved && involved.class == Array
      if involved.any? { |thing| thing.class == Hash }
        devs = []
        involved.each do |company|
          devs << company['company']['name'] if company['developer']
        end
        return devs if devs.present?
      end
    end
  end

  def convert_screenshots(g)
    screenshots = g['screenshots']
    scrns = []
    if screenshots && screenshots.class == Array
      if screenshots.any? { |thing| thing.class == Hash }
        filtered = screenshots.map { |thing| thing if thing.class == Hash }
        filtered = filtered.compact
        filtered.each do |screen|
          scrns << screen['image_id']
        end
        return scrns if scrns.present?
      end
    end
  end

  def compose_results
    puts '>> IGDBQUERY -> COMPOSE RESULTS:'
    @missing_games = []
    results = Agame.where(igdb_id: @games_ids).to_a
    @results += results
    if results.size != @games_ids.size
      puts ">> we are missing some games"
      res_ids = results.collect { |g| g.igdb_id }
      @missing_games = @games_ids - res_ids
      puts ">> missing games: #{ @missing_games }"
    else
      puts ">> we have ALL the games"
      @response_size = @results.size
    end
  end

  def initial_search
    puts '>> INITIAL SEARCH'
    results = request(@query[:endpoint], "f id; #{ @query[:body] }")
    puts ">> games before: #{ @games_ids.inspect }"
    if results.present?
      @games_ids = results.collect { |g| g['id']}
    end
    puts ">> games after: #{ @games_ids.inspect }"
  end

  def save_query
    puts '>> SAVING QUERY'
    query = Query.new(@query)
    query.results = @games_ids
    if query.save
      puts '>> query saved successfully'
    else
      puts '>> could not save query'
    end
  end

  def already_asked?
    puts '>> HAVE QUERY ALREADY BEEN ASKED?'
    results = Query.where(@query)
    if results.present?
      print '>> Such query already exists: '
      p ancestor = results.first
      if (ancestor.updated_at > DAYS_LIMIT.day.ago)
        puts '>> Found query is fresh!'
        puts '>> Copying games ids (if there are some)'
        @games_ids = ancestor.results if ancestor.results
        return true
      else
        puts '>> Found query is old, will be destroyed'
        ancestor.destroy
        return false
      end
    else
      puts '>> There is no such query!'
      return false
    end
  end

  def fix_duplicates(last_result_ids)
    @results.reject! { |game| last_result_ids.include?(game[:igdb_id]) }
  end

  def is_more?
    true if @response_size == RESULT_LIMIT && @offset < OFFSET_LIMIT
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

  def validate!
    errors.add(:base, :blank, message: "insert at least one character") if @input.blank?
    unless @platforms.values.any?
      errors.add(:base, :blank, message: "choose at least one platform")
    end
    !self.errors.any?
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  private
    def analyze_input(input)
      fixed_input = input.strip.downcase
      fixed_input.gsub!(/\s\s+/, ' ')
      type = :search
      if !fixed_input.match(/\A[*].*[^*]\z/).nil?
        fixed_input.delete_prefix!('*')
        type = :prefix
      elsif !fixed_input.match(/\A[^*].*[*]\z/).nil?
        fixed_input.delete_suffix!('*')
        type = :postfix
      elsif !fixed_input.match(/\A[*].*[*]\z/).nil?
        fixed_input.delete_prefix!('*').delete_suffix!('*')
        type = :infix
      end
      return [fixed_input, type]
    end

    def prepare_where
      start_where
      where_platforms
      where_categories
      where_erotic
      where_released
      end_where
    end

    def start_where
      if [:game, :char].include? @query_type
        case @type
        when :prefix then @where += "w (name ~ *#{@fixed_input.inspect}) "
        when :postfix then @where += "w (name ~ #{@fixed_input.inspect}*) "
        when :infix then @where += "w (name ~ *#{@fixed_input.inspect}*) "
        end
      elsif @query_type == :dev
        @where += "w ((name ~ "
        case @type
        when :prefix
          @where += "*#{@fixed_input.inspect}) | (slug ~ *#{@fixed_input.inspect})) "
        when :postfix
          @where += "#{@fixed_input.inspect}*) | (slug ~ #{@fixed_input.inspect}*)) "
        when :infix
          @where += "*#{@fixed_input.inspect}*) | (slug ~ *#{@fixed_input.inspect}*)) "
        else
          @where += "#{@fixed_input.inspect}) | (slug ~ #{@fixed_input.inspect})) "
        end
        @where += "& developed != null "
      end
    end

    def where_platforms
      unless @platforms.values.all?
        yes_categories = []
        yes_platforms = []

        @platforms.each do |k, v|
          if v
            yes_categories += PLATFORMS[k]["category"]
            yes_platforms += PLATFORMS[k]["platforms"]
          end
        end

        puts '>> IGDBQUERY -> CATEGORIES AND PLATFORMS:'
        print ">> categories: "
        p yes_categories
        print ">> platforms: "
        p yes_platforms

        is_category_added = false
        @where.blank? ? @where += 'w (' : @where += '& ('
        unless yes_categories.empty?
          is_category_added = true
          @where += "(platforms.category = (#{yes_categories.join(',')})) "
        end

        unless yes_platforms.empty?
          @where += '|' if is_category_added
          fixed_platforms = divide_list(yes_platforms, LIST_LIMIT)
          fixed_platforms.each do |part|
            @where += " (platforms = (#{part.join(',')})) |"
          end
          @where.chop!
        end

        @where.rstrip!
        @where += ') '
      end
    end

    def divide_list(list, limit)
      t = (list.size / 11)
      t += 1 if list.size%11 > 0

      result = []
      t.times do |_i|
        buf = []
        limit.times do |_g|
          buf << list.shift
        end
        result.push buf.compact
      end
      result
    end

    def where_categories
      unless @categories.values.all?
        no_categories = []
        no_categories.push 1 unless @categories['dlc']
        no_categories.push 2 unless @categories['expansion']
        no_categories.push 3 unless @categories['bundle']
        no_categories.push 4 unless @categories['standalone']
        @where.blank? ? @where += 'w ' : @where += '& '
        @where += "(category != (#{no_categories.join(',')})) "
      end
    end

    def where_released
      if @only_released
        @where.blank? ? @where += 'w ' : @where += '& '
        @where += "(first_release_date != null) "
      end
    end

    def where_erotic
      unless @erotic
        @where.blank? ? @where += 'w ' : @where += '& '
        @where += "(themes != (42)) "
      end
    end

    def end_where
      @where.rstrip!
      @where += '; ' if @where.present?
    end

    def prepare_search
      @search = "search #{@fixed_input.inspect}; " if @type == :search
    end

    def prepare_sort
      @sort = 'sort popularity desc; ' if @type != :search
    end

    def finish_query
      case @query_type
      when :game then endpoint = "games"
      when :dev then endpoint = "companies"
      when :char then endpoint = "characters"
      end
      body = @search + @where + @sort + "limit #{RESULT_LIMIT}; " + "offset #{@offset};"
      @query = { endpoint: endpoint, body: body }

      puts '>> IGDBQUERY -> PREPARED QUERY(without fields):'
      puts ">> query: #{ @query }"
    end

    def convert_to_games(lists, type)
      games = []
      key = @query_type == :dev ? "developed" : "games"
      lists.each do |list|
        xtra = list["name"]
        if list[key]
          list[key].each do |game|
            game['request'] = @query_type
            game['xtra'] = xtra unless xtra.nil?
            games.push game if game.class == Hash
          end
        end
      end
      games
    end

    def post_filters(results)
      puts "IGDB -> Applaying filters"

      # Only released games:
      if @only_released
        results.delete_if { |game| game["first_release_date"].nil?}
      end

      # Show Erotic games:
      unless @erotic
        results.delete_if { |game| game["themes"].include?(42) if game["themes"]}
      end

      # Show Dlc, Expansion, Bundle, Standalone:
      unless @categories['dlc']
        results.delete_if { |game| game["category"] == 1}
      end

      unless @categories['expansion']
        results.delete_if { |game| game["category"] == 2}
      end

      unless @categories['bundle']
        results.delete_if { |game| game["category"] == 3}
      end

      unless @categories['standalone']
        results.delete_if { |game| game["category"] == 4}
      end

      unless @platforms.values.all?

        puts "IGDB -> platforms/platforms.categories filters "
        puts "IGDB -> Plaforms array: #{@platforms}"

        yes_categories = []
        yes_platforms = []

        @platforms.each do |k, v|
          if v
            yes_categories += PLATFORMS[k]["category"]
            yes_platforms += PLATFORMS[k]["platforms"]
          end
        end

        puts "IGDB -> Prepared helper arrays:"
        puts "IGDB -> keep categories: #{yes_categories}"
        puts "IGDB -> keep platforms: #{yes_platforms}"

        results.keep_if do |game|
          a, b = [], []
          game["platforms"].each do |platform|
            a.push true if yes_categories.include?(platform["category"])
            b.push true if yes_platforms.include?(platform["id"])
          end
          puts "IGDB -> #{game["name"]}, #{game["platforms"]}"
          puts "IGDB -> categories: #{a}"
          puts "IGDB -> platforms #{b}"
          puts ". "*100
          puts "IGDB -> DELETE?, #{!(a.any? || b.any?)}"
          puts ". "*100
          a.any? || b.any?
        end
      end
      return results
    end
end
