class GatherDataForOverallGraphs < ApplicationService
  def initialize(obj:)
    @obj = obj
    @shared = obj.class.name == 'Share'
    @result = { stats: [] }
  end

  def call
    get_games
    set_basic_stats
    @result[:chart_1] = games_by_format
    @result[:chart_2] = games_by_collection
    @result[:chart_3] = games_by_platform
    @result[:chart_4] = games_by_release
    @result[:chart_5] = games_by_developer

    @result
  end

  private
    def get_games
      unless @shared
        @where_part = "WHERE collections.user_id='#{ @obj.id }'"
      else
        @where_part = "WHERE collections.id IN (#{ @obj.shared.join(', ') })"
      end

      sql = """SELECT collections.name, games.first_release_date, games.platform_name, games.physical, games.name, collection_games.created_at
               FROM collections
               INNER JOIN collection_games ON collections.id = collection_games.collection_id
               INNER JOIN games ON collection_games.game_id = games.id
               #{ @where_part }
               ORDER BY collection_games.created_at DESC;"""

      @games = ActiveRecord::Base.connection.execute(sql).values
    end

    def set_basic_stats
      @result[:stats] << @obj.created_at.to_f * 1000
      @result[:stats][1] = @games.size
      @result[:stats][6] = (!@games.empty? ? @games.first[4] : '-')
    end

    def games_by_format
      physical = @games.count { |g| g[3] }
      digital = @games.count { |g| g[3] == false }
      not_defined = @games.size - physical - digital
      chart_data = { 'Physical' => physical,
                     'Digital' => digital,
                     'Not defined' => not_defined }
      set_format_stat(chart_data)
      chart_data
    end

    def set_format_stat(format_data)
      max = format_data.values.max
      count = format_data.values.count(max)

      if count == 1
        @result[:stats][3] = format_data.key(max) + " (#{ max })"
      else
        res = ''
        format_data.each { |k,v| res += (k + ' & ') if v == max }
        @result[:stats][3] = "#{ res[0...-3] } (#{ max })".downcase
      end
    end

    def games_by_collection
      unless @shared
        collections = @obj.collections.pluck(:name)
      else
        collections = Collection.where(id: @obj.shared).pluck(:name)
      end
      coll_data = @games.map(&:first)
      largest = ['', 0]
      data = []
      collections.each do |c|
        val = coll_data.count(c)
        largest = [c, val] if val > largest.last
        data << [c, val]
      end

      set_dominant(2, largest)

      height = 2*15 + 2*8 + data.size*(15 + 8) - 7
      height = 600 if height > 600
      height = 250 if height < 250

      chart_data = { data: data, height: height }
    end

    def games_by_platform
      data = []
      plat_data = @games.map { |g| g[2].nil? ? '~~~' : g[2] }

      platforms = plat_data.uniq.sort

      dominant = ['', 0]
      platforms.each do |p|
        val = plat_data.count(p)
        dominant = [p, val] if val > dominant.last
        data << [p, val]
      end

      data.last[0] = 'Not defined' if !data.empty? && data.last[0] == '~~~'
      dominant[0] = 'Not defined' if dominant[0] == '~~~'

      set_dominant(4,dominant)

      height = 2*15 + 2*8 + data.size*(15 + 8) - 7
      height = 600 if height > 600
      height = 250 if height < 250

      chart_data = { data: data, height: height }
    end

    def games_by_release
      p_years, d_years, nd_years = [],[],[]
      @games.each do |g|
        if g[3]
          p_years << (g.second ? Time.at(g.second).year : 0)
        elsif g[3] == false
          d_years << (g.second ? Time.at(g.second).year : 0)
        else
          nd_years << (g.second ? Time.at(g.second).year : 0)
        end
      end

      datasets = [{ name: "Physical", data: [] },
                  { name: "Digital", data: [] },
                  { name: "Not defined", data: [] }]

      all_years = p_years.union(d_years).union(nd_years).sort

      total_values = []
      all_years.each do |y|
        val = p_years.count(y), d_years.count(y), nd_years.count(y)
        datasets[0][:data] << [y, val[0]]
        datasets[1][:data] << [y, val[1]]
        datasets[2][:data] << [y, val[2]]
        total_values << val.sum
      end

      if datasets[0][:data].assoc(0)
        datasets[0][:data][0][0] = '(no data)'
        datasets[1][:data][0][0] = '(no data)'
        datasets[2][:data][0][0] = '(no data)'
      end

      unless total_values.empty?
        max = total_values.max
        chrt_max = round_to(max, 5)
        limit = (chrt_max * 0.08).round
        p_labels = datasets[0][:data].map { |g| g[1] >= limit && g[1] != 0 }
        d_labels = datasets[1][:data].map { |g| g[1] >= limit && g[1] != 0 }
        nd_labels = datasets[2][:data].map { |g| g[1] >= limit && g[1] != 0 }
      end

      chart_data = { data: datasets,
                  p_labels: p_labels,
                  d_labels: d_labels,
                  nd_labels: nd_labels,
                  max: chrt_max }
    end

    def games_by_developer
      sql = """SELECT developers.name, games.physical
               FROM collection_games
               INNER JOIN collections ON collection_games.collection_id = collections.id
               LEFT JOIN developer_games ON collection_games.game_id=developer_games.game_id
               LEFT JOIN developers ON developer_games.developer_id=developers.id
               INNER JOIN games ON collection_games.game_id = games.id
               #{ @where_part };"""

      r = ActiveRecord::Base.connection.execute(sql).values

      r.map! { |e| e[0].nil? ? ['~~~', e[1]] : e } if r.assoc(nil)

      p_devs, d_devs, nd_devs = [], [], []
      all_devs = []
      r.each do |r|
        all_devs << r.first
        if r.last
          p_devs << r.first
        elsif r.last == false
          d_devs << r.first
        else
          nd_devs << r.first
        end
      end
      all_devs.uniq!

      p_dataset, d_dataset, nd_dataset = [], [], []

      total_values = []
      dominant = ['', 0]
      all_devs.sort.each do |d|
        values = p_devs.count(d), d_devs.count(d), nd_devs.count(d)
        d = d[0...31] + '...' if d.size >= 35
        p_dataset << [d, values[0]]
        d_dataset << [d, values[1]]
        nd_dataset << [d, values[2]]
        sum = values.sum
        total_values << sum
        dominant = [d, sum] if sum > dominant.last
      end

      if p_dataset.last[0] == '~~~'
        p_dataset.last[0] = '(no data)'
        d_dataset.last[0] = '(no data)'
        nd_dataset.last[0] = '(no data)'
      end

      dominant[0] = '(no data)' if dominant[0] == '~~~'

      set_dominant(5, dominant)

      num_of_devs = all_devs.size
      sep = (num_of_devs / 2.0).round

      p_1 = p_dataset.slice(0...sep)
      p_2 = p_dataset.slice(sep..)
      d_1 = d_dataset.slice(0...sep)
      d_2 = d_dataset.slice(sep..)
      nd_1 = nd_dataset.slice(0...sep)
      nd_2 = nd_dataset.slice(sep..)

      max = total_values.max
      limit = (max * 0.08).round unless total_values.empty?
      p_labels_1 = p_1.map { |g| g[1] >= limit && g[1] != 0 }
      p_labels_2 = p_2.map { |g| g[1] >= limit && g[1] != 0 }
      d_labels_1 = d_1.map { |g| g[1] >= limit && g[1] != 0 }
      d_labels_2 = d_2.map { |g| g[1] >= limit && g[1] != 0 }
      nd_labels_1 = nd_1.map { |g| g[1] >= limit && g[1] != 0 }
      nd_labels_2 = nd_2.map { |g| g[1] >= limit && g[1] != 0 }

      chart_data = { data_1: [{ name: "Physical", data: p_1 },
                           { name: "Digital", data: d_1 },
                           { name: "Not defined", data: nd_1 }],
                 data_2: [{ name: "Physical", data: p_2 },
                          { name: "Digital", data: d_2 },
                          { name: "Not defined", data: nd_2 }],
                 p_labels_1: p_labels_1,
                 p_labels_2: p_labels_2,
                 d_labels_1: d_labels_1,
                 d_labels_2: d_labels_2,
                 nd_labels_1: nd_labels_1,
                 nd_labels_2: nd_labels_2,
                 height_1: 7 + 31 + 32 + sep * 20,
                 height_2: 7 + 31 + 32 + (num_of_devs - sep) * 20,
                 max: max
               }
    end

    def set_dominant(id, dominant)
      result = dominant[1] == 0 ? '-' : "#{dominant[0]} (#{dominant[1]})"
      @result[:stats][id] = result
    end

    def round_to(a, const)
      res = (a / const) * const
      res += const if a % const > 0
      res
    end
end
