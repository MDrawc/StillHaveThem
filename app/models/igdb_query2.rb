require 'net/https'

class IgdbQuery2
  include ActiveModel::Validations
  attr_reader :query, :offset, :results, :last_input
  validates :query, presence: true

  FIELDS_GAMES = ["name,
                   first_release_date,
                   status,
                   category,
                   cover.image_id,
                   platforms.name"].join(',')

  FIELDS_DEV = ["name",
                "developed.name",
                "developed.first_release_date",
                "developed.status",
                "developed.category",
                "developed.cover.image_id",
                "developed.platforms.name",
                "developed.platforms.category"].join(',')

  PLATFORMS = { "console" => { "category" => [1], "platforms" => [160, 36, 45, 47, 56]},
                "arcade" => { "category" => [2], "platforms" => [52]},
                "portable" => { "category" => [5], "platforms" => []},
                "pc" => { "category" => [], "platforms" => [6, 13]},
                "linux" => { "category" => [], "platforms" => [3, 92]},
                "mac" => { "category" => [], "platforms" => [14]},
                "mobile" => { "category" => [], "platforms" => [39, 73, 34, 55]},
                "computer" => { "category" => [6], "platforms" => []},
                "other" => { "category" => [], "platforms" => [132, 82, 113]},
  }

  RESULT_LIMIT = 50
  OFFSET_LIMIT = 150
  LIST_LIMIT = 10

  def initialize(obj, offset = 0)
    @last_input = obj

    @query_type = :game

    @query = obj['inquiry']
    @offset = offset
    @fixed_query, @type = analyze_query(@query)
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

    @response_size = 0

    @results = []

    puts 'IGDB-> INITIALIZED:'
    puts "query: #{@query}"
    puts "fixed_query: #{@fixed_query}"
    puts "type: #{@type}"
    puts "platforms: #{@platforms}"
    puts "categories: #{@categories}"
    puts "erotic: #{@erotic}"
    puts "only_released: #{@only_released}"
  end

  def search
    case @query_type
    when :game then search_game
    when :dev  then search_dev
    when :year then search_year
    end
  end

  def fix_duplicates(last_result_ids)
    @results.reject! { |game| last_result_ids.include?(game["id"])}
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
    def search_game
      start_where
      where_platforms
      where_categories
      where_erotic
      where_released
      end_where
      prepare_search
      prepare_sort
      request(@offset)
    end

    def search_dev
      start_where
      end_where
      request(@offset)
      apply_filters
    end

    def search_year
    end

    def analyze_query(query)
      fixed_query = query.strip
      fixed_query.gsub!(/\s\s+/, ' ')
      type = :search
      if !fixed_query.match(/\A[*].*[^*]\z/).nil?
        fixed_query.delete_prefix!('*')
        type = :prefix
      elsif !fixed_query.match(/\A[^*].*[*]\z/).nil?
        fixed_query.delete_suffix!('*')
        type = :postfix
      elsif !fixed_query.match(/\A[*].*[*]\z/).nil?
        fixed_query.delete_prefix!('*').delete_suffix!('*')
        type = :infix
      end
      return [fixed_query, type]
    end

    def start_where

      if @query_type == :game

        case @type
        when :prefix then @where += "w (name ~ *#{@fixed_query.inspect}) "
        when :postfix then @where += "w (name ~ #{@fixed_query.inspect}*) "
        when :infix then @where += "w (name ~ *#{@fixed_query.inspect}*) "
        end

      elsif @query_type == :dev

        @where += "w ((name ~ "
        case @type
        when :prefix
          @where += "*#{@fixed_query.inspect}) | (slug ~ *#{@fixed_query.inspect})) "
        when :postfix
          @where += "#{@fixed_query.inspect}*) | (slug ~ #{@fixed_query.inspect}*)) "
        when :infix
          @where += "*#{@fixed_query.inspect}*) | (slug ~ *#{@fixed_query.inspect}*)) "
        else
          @where += "#{@fixed_query.inspect}) | (slug ~ #{@fixed_query.inspect})) "
        end
        @where += "& developed != null "
      end
    end

    def where_platforms
      unless @platforms.values.all?
        if calculate_rm_cost > LIST_LIMIT
          puts 'IGDB-> ADDING PLATFORMS'
          remove_platforms # TEmporary for testing only
          # add_platforms
        else
          puts 'IGDB-> REMOVING PLATFORMS'
          remove_platforms
        end
      end
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
        @where += '(first_release_date != null) '
      end
    end

    def where_erotic
      unless @erotic
        @where.blank? ? @where += 'w ' : @where += '& '
        @where += '(themes != (42)) '
      end
    end

    def end_where
      @where.rstrip!
      @where += '; ' if @where.present?
    end

    def prepare_search
      @search = "search #{@fixed_query.inspect}; " if @type == :search
    end

    def prepare_sort
      @sort = 'sort popularity desc; ' if @type != :search
    end

    def calculate_rm_cost
      result = 0
      @platforms.each do |k, _v|
      unless @platforms[k]
        result += PLATFORMS[k]["platforms"].size
      end
      end

      puts "IGDB-> RM_COST: #{result}"
      result
    end

    def request(offset)
      http = Net::HTTP.new('api-v3.igdb.com', 80)

      case @query_type
      when :game
        url_end = "games"
        fields = FIELDS_GAMES
      when :dev
        url_end = "companies"
        fields = FIELDS_DEV
      when :year then url_end = "games"
      end

      request = Net::HTTP::Get.new(URI("https://api-v3.igdb.com/#{url_end}"),
       { 'user-key' => ENV['IGDB_KEY'] })

      request.body = 'f ' + fields + '; ' + @search + @where + @sort +
       "limit #{RESULT_LIMIT}; " + "offset #{offset};"

      puts 'IGDB-> REQUEST:'
      puts request.body

      @results = JSON.parse http.request(request).body

      @results = convert_to_games(@results) if @query_type == :dev

      @response_size = @results.size

      puts 'IGDB-> RECEIVED RESULTS:'
      puts @results
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

    def add_platforms
      yes_categories = []
      yes_platforms = []

      # Add big consoles (with Nintendo eShop, XBLA, PSN, Virtual Console):
      if @platforms['console']
         yes_categories += PLATFORMS["console"]["category"]
         yes_platforms += PLATFORMS["console"]["platforms"]
      end
      # Add arcade:
      if @platforms['arcade']
         yes_categories += PLATFORMS["arcade"]["category"]
         yes_platforms += PLATFORMS["arcade"]["platforms"]
      end
      # Add portable consoles (with Ngage):
      if @platforms['portable']
         yes_categories += PLATFORMS["portable"]["category"]
         yes_platforms += PLATFORMS["portable"]["platforms"]
      end
      # Add PC (with PC DOS):
      if @platforms['pc']
         yes_categories += PLATFORMS["pc"]["category"]
         yes_platforms += PLATFORMS["pc"]["platforms"]
      end
      # Add Linux (with SteamOS):
      if @platforms['linux']
         yes_categories += PLATFORMS["linux"]["category"]
         yes_platforms += PLATFORMS["linux"]["platforms"]
      end
      # Add Mac:
      if @platforms['mac']
         yes_categories += PLATFORMS["mac"]["category"]
         yes_platforms += PLATFORMS["mac"]["platforms"]
      end
      # Add mobile (iOs, BlackBerry Os, Android):
      if @platforms['mobile']
         yes_categories += PLATFORMS["mobile"]["category"]
         yes_platforms += PLATFORMS["mobile"]["platforms"]
      end
      # Add old computers:
      if @platforms['computer']
         yes_categories += PLATFORMS["computer"]["category"]
         yes_platforms += PLATFORMS["computer"]["platforms"]
      end
      # Add other (Amazon Fire TV, Web browser, OnLive Game System):
         if @platforms['other']
         yes_categories += PLATFORMS["other"]["category"]
         yes_platforms += PLATFORMS["other"]["platforms"]
      end

      is_category_added = false

      @where.blank? ? @where += 'w (' : @where += '& ('

      unless yes_categories.empty?
        is_category_added = true
        @where += "(platforms.category = (#{yes_categories.join(',')})) "
      end

      unless yes_platforms.empty?
        @where += '| ' if is_category_added
        @where += "(platforms = (#{yes_platforms.join(',')})) "
      end

      @where.rstrip!
      @where += ') '
    end

    def remove_platforms
      no_categories = []
      no_platforms = []

      # Add big consoles (with Nintendo eShop, XBLA, PSN, Virtual Console):
      unless @platforms['console']
         no_categories += PLATFORMS["console"]["category"]
         no_platforms += PLATFORMS["console"]["platforms"]
      end
      # Add arcade:
      unless @platforms['arcade']
         no_categories += PLATFORMS["arcade"]["category"]
         no_platforms += PLATFORMS["arcade"]["platforms"]
      end
      # Add portable consoles (with Ngage):
      unless @platforms['portable']
         no_categories += PLATFORMS["portable"]["category"]
         no_platforms += PLATFORMS["portable"]["platforms"]
      end
      # Add PC (with PC DOS):
      unless @platforms['pc']
         no_categories += PLATFORMS["pc"]["category"]
         no_platforms += PLATFORMS["pc"]["platforms"]
      end
      # Add Linux (with SteamOS):
      unless @platforms['linux']
         no_categories += PLATFORMS["linux"]["category"]
         no_platforms += PLATFORMS["linux"]["platforms"]
      end
      # Add Mac:
      unless @platforms['mac']
         no_categories += PLATFORMS["mac"]["category"]
         no_platforms += PLATFORMS["mac"]["platforms"]
      end
      # Add mobile (iOs, BlackBerry Os, Android):
      unless @platforms['mobile']
         no_categories += PLATFORMS["mobile"]["category"]
         no_platforms += PLATFORMS["mobile"]["platforms"]
      end
      # Add old computers:
      unless @platforms['computer']
         no_categories += PLATFORMS["computer"]["category"]
         no_platforms += PLATFORMS["computer"]["platforms"]
      end
      # Add other (Amazon Fire TV, Web browser, OnLive Game System):
      unless @platforms['other']
         no_categories += PLATFORMS["other"]["category"]
         no_platforms += PLATFORMS["other"]["platforms"]
      end

      is_category_removed = false

      @where.blank? ? @where += 'w (' : @where += '& ('

      unless no_categories.empty?
        is_category_removed = true
        @where += "(platforms.category != (#{no_categories.join(',')})) "
      end

      unless no_platforms.empty?
        @where += '& ' if is_category_removed
        @where += "(platforms != (#{no_platforms.join(',')})) "
      end

      @where.rstrip!
      @where += ') '
    end

    def apply_filters
      puts "IGDB -> Applaying filters"

      # Only released games:
      if @only_released
        @results.delete_if { |game| game["first_release_date"].nil?}
      end

      # Show Erotic games:
      unless @erotic
        @results.delete_if { |game| game["themes"].include?(42) if game["themes"]}
      end

      # Show Dlc, Expansion, Bundle, Standalone:
      unless @categories['dlc']
        @results.delete_if { |game| game["category"] == 1}
      end

      unless @categories['expansion']
        @results.delete_if { |game| game["category"] == 2}
      end

      unless @categories['bundle']
        @results.delete_if { |game| game["category"] == 3}
      end

      unless @categories['standalone']
        @results.delete_if { |game| game["category"] == 4}
      end

      unless @platforms.values.all?

        puts "IGDB -> platforms/platforms.categories filters "
        puts "IGDB -> Plaforms array: #{@platforms}"

        # PLATFORMS:
        yes_categories = []
        yes_platforms = []
         # Add big consoles (with Nintendo eShop, XBLA, PSN, Virtual Console):
        if @platforms['console']
           yes_categories += PLATFORMS["console"]["category"]
           yes_platforms += PLATFORMS["console"]["platforms"]
        end
        # Add arcade:
        if @platforms['arcade']
           yes_categories += PLATFORMS["arcade"]["category"]
           yes_platforms += PLATFORMS["arcade"]["platforms"]
        end
        # Add portable consoles (with Ngage):
        if @platforms['portable']
           yes_categories += PLATFORMS["portable"]["category"]
           yes_platforms += PLATFORMS["portable"]["platforms"]
        end
        # Add PC (with PC DOS):
        if @platforms['pc']
           yes_categories += PLATFORMS["pc"]["category"]
           yes_platforms += PLATFORMS["pc"]["platforms"]
        end
        # Add Linux (with SteamOS):
        if @platforms['linux']
           yes_categories += PLATFORMS["linux"]["category"]
           yes_platforms += PLATFORMS["linux"]["platforms"]
        end
        # Add Mac:
        if @platforms['mac']
           yes_categories += PLATFORMS["mac"]["category"]
           yes_platforms += PLATFORMS["mac"]["platforms"]
        end
        # Add mobile (iOs, BlackBerry Os, Android):
        if @platforms['mobile']
           yes_categories += PLATFORMS["mobile"]["category"]
           yes_platforms += PLATFORMS["mobile"]["platforms"]
        end
        # Add old computers:
        if @platforms['computer']
           yes_categories += PLATFORMS["computer"]["category"]
           yes_platforms += PLATFORMS["computer"]["platforms"]
        end
        # Add other (Amazon Fire TV, Web browser, OnLive Game System):
           if @platforms['other']
           yes_categories += PLATFORMS["other"]["category"]
           yes_platforms += PLATFORMS["other"]["platforms"]
        end

        puts "IGDB -> Prepared helper arrays:"
        puts "IGDB -> keep categories: #{yes_categories}"
        puts "IGDB -> keep platforms: #{yes_platforms}"

        @results.keep_if do |game|
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
    end
end
