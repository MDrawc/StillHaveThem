require 'net/https'

class IgdbQuery
  extend ActiveModel::Naming
  attr_reader :errors, :input, :query, :query_type, :offset, :results

  RESULT_LIMIT = 50
  OFFSET_LIMIT = 150
  LIST_LIMIT = 10
  DAYS_LIMIT = 7

  FIELDS_GAMES = ["name",
  "first_release_date",
  "themes",
  "screenshots.image_id",
  "summary",
  "status",
  "category",
  "cover.image_id",
  "cover.width",
  "cover.height",
  "involved_companies.company.name",
  "involved_companies.developer",
  "platforms.category",
  "platforms.name"].join(',')

  FIELDS_DEV = ["name",
  "developed.name",
  "developed.themes",
  "developed.first_release_date",
  "developed.screenshots.image_id",
  "developed.summary",
  "developed.status",
  "developed.category",
  "developed.involved_companies.company.name",
  "developed.involved_companies.developer",
  "developed.cover.image_id",
  "developed.cover.width",
  "developed.cover.height",
  "developed.platforms.category",
  "developed.platforms.name"].join(',')

  FIELDS_CHAR = ["name",
  "games.name",
  "games.themes",
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

  def initialize(obj = nil, offset = 0, query = nil)
    @errors = ActiveModel::Errors.new(self)
    @results = []
    @response_size = 0

    puts '>> [ Initializing ]'
    @offset = offset
    unless query
      @query_type = obj['query_type'].to_sym
      @input = obj['inquiry']
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

      puts ">> Using input: #{ @input }"
      puts ">> Query type: #{ @query_type }"
      puts ">> Corrected input: #{ @fixed_input }"
      puts ">> Input type: #{ @type }"
      puts ">> Offset: #{ @offset}"
      puts ">> Platforms: #{ @platforms }"
      puts ">> Categories: #{ @categories }"
      puts ">> Erotic: #{ @erotic }"
      puts ">> Only released: #{ @only_released }"
    else
      puts ">> Using query (load more feature): #{ query.inspect }"
      @query = change_offset(query, @offset)
      case @query[:endpoint]
      when 'games' then @query_type = :game
      when 'companies' then @query_type = :dev
      when 'characters' then @query_type = :char
      end
      puts ">> New query: #{ @query.inspect }"
    end
  end

  def search
    prepare_query unless @query
    unless already_asked?
      initial_search
      save_query
    end
    compose_results if @games_ids
    full_search if @missing_games.present?
  end

  def fix_duplicates(last_result_ids)
    @results.reject! { |game| last_result_ids.include?(game[:igdb_id]) }
  end

  def is_more?
    true if @response_size == RESULT_LIMIT && @offset < OFFSET_LIMIT
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
    def change_offset(query, offset)
      puts '>> [ Changing Offset ]'
      query[:body].sub!("offset #{ @offset - RESULT_LIMIT }", "offset #{ @offset }")
      query
    end

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

    def already_asked?
      puts '>> [ Checking if query exists in DB ]'
      if (results = Query.where(@query)).present?
        ancestor = results.first
        puts ">> Query already exists: #{ ancestor.inspect }"
        if (ancestor.updated_at > DAYS_LIMIT.day.ago)
          puts '>> Query is considered actual. Copying results(games ids).'
          @games_ids = ancestor.results if ancestor.results
          @addl = ancestor.addl if ancestor.addl
          @response_size = ancestor.response if ancestor.response
          return true
        else
          puts '>> Query is too old and will be deleted.'
          ancestor.destroy
          return false
        end
      else
        puts '>> Query does not exist in DB.'
        return false
      end
    end

    def initial_search
      puts '>> [ Initial Search ]'
      case @query_type
      when :game
        results = request(@query[:endpoint], "f id; #{ @query[:body] }")
        if results.present?
          @games_ids = results.map { |g| g['id']}
        end
      when :dev
        results = request(@query[:endpoint], "f name, developed; #{ @query[:body] }")
        if results.present?
          @games_ids = results.map { |d| d['developed']}.flatten.compact
          @addl = get_addl(results)
        end
      when :char
        results = request(@query[:endpoint], "f name, games; #{ @query[:body] }")
        if results.present?
          @games_ids = results.map { |c| c['games']}.flatten.compact
          @addl = get_addl(results)
        end
      end
      print ">> Received #{ @games_ids.size } games ids: " if @games_ids
      puts @games_ids.inspect
      puts ">> Response size: #{ @response_size }"
      puts ">> Additional info's size: #{ @addl.size }" if @addl
    end

    def save_query
      puts '>> [ Saving Query ]'
      query = Query.new(@query)
      query.results = @games_ids
      query.addl = @addl unless @query_type == :game
      query.response = @response_size
      puts '>> Query saved successfully.' if query.save
    end

    def get_addl(results)
      puts '>> [ Creating Additional Info Array ]'
      case @query_type
      when :dev then key = 'developed'
      when :char then key = 'games'
      end

      addl = []
      results.each do |c|
          c[key].size.times { addl << c['name'] } if c[key]
      end

      puts ">> Additional info array: #{ addl }"
      addl
    end

    def add_addl_to_games(res)
      puts '>> [ Adding Additional Info to Results ]'
      res.each_with_index { |g, i| g[:addl] = @addl[i] }
    end

    def compose_results
      puts '>> [ Composing Results ]'

      # Finds stored in DB games (ignores duplicates):
      res = Agame.where(igdb_id: @games_ids)

      # Sort but also recreate duplicates (needed in character search):
      unless @query_type == :game
        res = @games_ids.map { |id| res.find { |g| g.igdb_id == id } }.compact
      end

      @results = res.as_json.map(&:symbolize_keys)

      if res.size == @games_ids.size
        unless @query_type == :game
          @results = add_addl_to_games(@results)
          @results = post_filters(@results)
        end
        puts '>> DB have all the games. Searching IGDB unnecessary.'
      else
        @missing_games = @games_ids - res.map { |g| g[:igdb_id] }
        puts ">> DB is missing games(igdb_id): #{ @missing_games }"
        puts '>> Searching IGDB for full set of information is necessary.'
      end
    end

    def full_search
      puts '>> [ Full Search ]'
      case @query_type
      when :game then fields = FIELDS_GAMES
      when :dev then fields = FIELDS_DEV
      when :char then fields = FIELDS_CHAR
      end

      results = request(@query[:endpoint], "f #{ fields }; #{ @query[:body] }")

      unless @query_type == :game
        @addl = get_addl(results)
        results = convert_to_games(results)
      end

      puts ">> Received #{ @response_size } results."

      convert_and_save(results)
    end

    def convert_and_save(results)

      puts '>> [ Preparing Results ]'
      puts '>> Converting games.'

      converted = []
      results.each do |g|
        c = {}
        c[:igdb_id] = g['id']
        c[:name] = g['name']
        c[:themes] = g['themes']
        c[:first_release_date] = g['first_release_date']
        c[:summary] = g['summary']
        c[:status] = g['status']
        c[:category] = g['category']
        if g['cover']
          c[:cover] = g['cover']['image_id']
          c[:cover_height] = g['cover']['height']
          c[:cover_width]= g['cover']['width']
        else
          c[:cover], c[:cover_height], c[:cover_width] = nil
        end
        if g['platforms']
          c[:platforms] = g['platforms'].map { |platform| platform['id'] }
          c[:platforms_names] = g['platforms'].map { |platform| platform['name'] }
          c[:platforms_categories] = g['platforms'].map { |platform| platform['category'] }
        else
          c[:platforms], c[:platforms_names], c[:platforms_categories] = nil
        end
        c[:developers] = convert_devs(g)
        c[:screenshots] = convert_screenshots(g)
        converted << c
      end

      already_exists = converted.select do |g|
        @results.any? { |o| o[:igdb_id] == g[:igdb_id] }
      end

      new_games = converted - already_exists

      res_to_h = @results.map { |g| g.except(:id, :created_at, :updated_at) }
      to_update = already_exists - res_to_h

      puts ">> Converted games: #{ converted.map { |g| g[:name] } }"
      puts ">> Already existing games: #{ already_exists.map { |g| g[:name] } }"
      puts ">> New games: #{ new_games.map { |g| g[:name] } }"
      puts ">> Games that needs update: #{ to_update.map { |g| g[:name] } }"

      update_ids = to_update.map do |u|
        @results.select { |g| g[:igdb_id] == u[:igdb_id] }.first[:id]
      end

      puts ">> Games that needs update - ids: #{ update_ids }"
      puts ">> Saving #{new_games.size} new games"
      Agame.create(new_games)

      puts ">> Updating #{to_update.size} existing games"
      Agame.update(update_ids, to_update)

      unless @query_type == :game
        converted = add_addl_to_games(converted)
        converted = post_filters(converted)
      end

      @results = converted

      puts ">> Results size: #{ @results.size }"
    end

    def request(endpoint, body)
      puts '>> [ Sending Request ]'
      http = Net::HTTP.new('api-v3.igdb.com', 443)
      http.use_ssl = true
      request = Net::HTTP::Get.new(URI("https://api-v3.igdb.com/#{ endpoint }"),
       { 'user-key' => ENV['IGDB_KEY'] })
      request.body = body
      puts ">> Full request: #{ request.body }"
      begin
        results = JSON.parse http.request(request).body
        rescue JSON::ParserError
          results = []
      end
      @response_size = results.size
      return results
    end

    def convert_to_games(results)
      games = []
      key = @query_type == :dev ? "developed" : "games"
      results.each do |record|
        record[key].each { |g| games << g if g.class == Hash} if record[key]
      end
      games
    end

    def post_filters(results)
      puts '>> [ Applaying Post Filters for Dev or Char Search ]'
      if @only_released
        results.delete_if { |game| game[:first_release_date].nil?}
      end

      unless @erotic
        results.delete_if { |game| game[:themes].include?(42) if game[:themes]}
      end

      unless @categories['dlc']
        results.delete_if { |game| game[:category] == 1}
      end

      unless @categories['expansion']
        results.delete_if { |game| game[:category] == 2}
      end

      unless @categories['bundle']
        results.delete_if { |game| game[:category] == 3}
      end

      unless @categories['standalone']
        results.delete_if { |game| game[:category] == 4}
      end

      unless @platforms.values.all?
        puts ">> Plaforms array: #{@platforms}"

        yes_categories = []
        yes_platforms = []
        @platforms.each do |k, v|
          if v
            yes_categories += PLATFORMS[k]["category"]
            yes_platforms += PLATFORMS[k]["platforms"]
          end
        end

        puts ">> Prepared helper arrays:"
        puts ">> - keep categories: #{yes_categories}"
        puts ">> - keep platforms: #{yes_platforms}"

        results.keep_if do |game|
          a = (yes_categories & game[:platforms_categories])
          b = (yes_platforms & game[:platforms])
          puts ">> [ #{ game[:name] } ], released on platforms: #{ game[:platforms] }"
          puts ">> - common categories: #{ a }"
          puts ">> - common platforms: #{ b }"
          puts ". "*40
          puts ">> DELETED?, #{ !(a.any? || b.any?) ? 'Yes' : 'No' }"
          puts ". "*40
          a.any? || b.any?
        end
      end
      return results
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

        puts '>> [ Preparing \'where\' Part of Query - Categories & Platforms]'
        puts ">> Accepted categories: #{ yes_categories }"
        puts ">> Accepted platforms: #{ yes_platforms }"

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
      puts '>> [ Preparing Query (Hash) ]'
      case @query_type
      when :game then endpoint = "games"
      when :dev then endpoint = "companies"
      when :char then endpoint = "characters"
      end
      body = @search + @where + @sort + "limit #{RESULT_LIMIT}; " + "offset #{@offset};"
      @query = { endpoint: endpoint, body: body }
      puts ">> Query: #{ @query }"
    end
end
