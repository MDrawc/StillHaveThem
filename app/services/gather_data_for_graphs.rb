class GatherDataForGraphs < ApplicationService
  def initialize(collection:)
    @collection = collection
    @result = { stats: [] }
  end

  def call
    get_collection_info
    get_games
    set_basic_stats
    @result[:chart_1] = against_the_rest
    if @needs_platform
      @result[:chart_2] = games_by_format
      @result[:chart_3] = games_by_platform
    else
      @result[:stats] << '-' << '-'
    end
    @result[:chart_4] = games_by_release
    @result[:chart_5] = games_by_developers
    last_game_stat
    @result
  end

  private
    def get_collection_info
      @needs_platform = @collection.needs_platform
      @user_id = @collection.user_id
    end

    def get_games
      @games = @collection.games.pluck(:first_release_date,
                                       :platform_name,
                                       :physical,
                                       :name)
    end

    def set_basic_stats
      @result[:stats] << @collection.created_at.to_f * 1000
      @result[:stats] << (@needs_platform ? 'yes' : 'no')
      @result[:stats] << @games.size
    end

    def against_the_rest
      sql = """SELECT COUNT(collections.id)
           FROM collections
           INNER JOIN collection_games ON collections.id = collection_games.collection_id
           WHERE collections.user_id = '#{@user_id}';"""

      overall = ActiveRecord::Base.connection.execute(sql).values[0][0]
      num_of_games = @games.size
      chart_data = [[@collection.name, num_of_games]]
      chart_data << ['Other collections', overall - num_of_games]
    end

    def games_by_format
      unless @games.empty?
        physical = @games.count {|g| g[2] == true}
        digital = @games.size - physical

        set_format_stat(physical, digital)

        chart_data = [['Physical', physical]]
        chart_data << ['Digital', digital]
      else
        @result[:stats] << '-'
        return nil
      end
    end

    def set_format_stat(physical, digital)
      if physical > digital
        @result[:stats] << "physical (#{physical})"
      elsif physical == digital
        @result[:stats] << "physical & digital (#{digital})"
      else
        @result[:stats] << "digital (#{digital})"
      end
    end

    def games_by_platform
      data = []
      platforms = @games.map(&:second)

      dominant = ['', 0]
      platforms.uniq.sort.each do |p|
        val = platforms.count(p)
        dominant = [p, val] if val > dominant.last
        data << [p, val]
      end

      set_platform_stat(dominant)

      height = 2*15 + 2*8 + data.size*(15 + 8) - 7
      height = 600 if height > 600
      height = 250 if height < 250
      chart_data = { data: data, height: height }
    end

    def set_platform_stat(dominant)
      result = @games.empty? ? '-' : "#{dominant[0]} (#{dominant[1]})"
      @result[:stats] << result
    end

    def games_by_release
      if @needs_platform
        p_years, d_years = [],[]
        @games.each do |g|
          if g[2]
            p_years << (g.first ? Time.at(g.first).year : 0)
          else
            d_years << (g.first ? Time.at(g.first).year : 0)
          end
        end

        datasets = [ { name: "Physical", data: [] },
          { name: "Digital", data: [] }]

        all_years = p_years.union(d_years).sort

        total_values = []
        all_years.each do |y|
          val = p_years.count(y), d_years.count(y)
          datasets[0][:data] << [y, val[0]]
          datasets[1][:data] << [y, val[1]]
          total_values << val.sum
        end

        if datasets[0][:data].assoc(0)
          datasets[0][:data][0][0] = '(no data)'
          datasets[1][:data][0][0] = '(no data)'
        end

        unless total_values.empty?
          max = total_values.max
          chrt_max = round_to(max, 5)
          limit = (chrt_max * 0.08).round
          p_labels = datasets[0][:data].map { |g| g[1] >= limit && g[1] != 0 }
          d_labels = datasets[1][:data].map { |g| g[1] >= limit && g[1] != 0 }
        end

        chart_data = { data: datasets, p_labels: p_labels, d_labels: d_labels, max: chrt_max }
      else
        years = @games. map do |g|
          if g.first
            res = Time.at(g.first).year
          else
            res = 0
          end
          res
        end

        data = []
        values = []
        years.uniq.sort.each do |y|
          val = years.count(y)
          data << [y, val]
          values << val
        end

        data[0][0] = '(no data)' if data.assoc(0)

        unless values.empty?
          max = values.max
          chrt_max = round_to(max, 5)
          limit = (chrt_max * 0.08).round
          labels = data.map { |g| g[1] >= limit && g[1] != 0 }
        end

        chart_data = { data: data, labels: labels, max: chrt_max }
      end
    end

    def games_by_developers
      if @needs_platform

        sql = """SELECT developers.name, games.physical
                 FROM collection_games
                 LEFT JOIN developer_games ON collection_games.game_id=developer_games.game_id
                 LEFT JOIN developers ON developer_games.developer_id=developers.id
                 INNER JOIN games ON collection_games.game_id = games.id
                 WHERE collection_id = '#{@collection.id}';"""

        r = ActiveRecord::Base.connection.execute(sql).values

        r.map! { |e| e[0].nil? ? ['~~~', e[1]] : e } if r.assoc(nil)

        p_devs, d_devs = [], []
        all_devs = []
        r.each do |r|
          all_devs << r.first
          if r.last
            p_devs << r.first
          else
            d_devs << r.first
          end
        end
        all_devs.uniq!
        p_dataset, d_dataset = [], []

        total_values = []
        dominant = ['', 0]
        all_devs.sort.each do |d|
          values = p_devs.count(d), d_devs.count(d)
          d = d[0...31] + '...' if d.size >= 35
          p_dataset << [d, values[0]]
          d_dataset << [d, values[1]]
          sum = values.sum
          total_values << sum
          dominant = [d, sum] if sum > dominant.last
        end

        if p_dataset.last && p_dataset.last[0] == '~~~'
          p_dataset.last[0] = '(no data)'
          d_dataset.last[0] = '(no data)'
        end

        dominant[0] = '(no data)' if dominant[0] == '~~~'

        set_developer_stat(dominant)

        num_of_devs = all_devs.size
        sep = (num_of_devs / 2.0).round

        p_1 = p_dataset.slice(0...sep)
        p_2 = p_dataset.slice(sep..)
        d_1 = d_dataset.slice(0...sep)
        d_2 = d_dataset.slice(sep..)

        max = total_values.max

        limit = (max * 0.08).round unless total_values.empty?
        p_labels_1 = p_1.map { |g| g[1] >= limit && g[1] != 0 }
        p_labels_2 = p_2.map { |g| g[1] >= limit && g[1] != 0 }
        d_labels_1 = d_1.map { |g| g[1] >= limit && g[1] != 0 }
        d_labels_2 = d_2.map { |g| g[1] >= limit && g[1] != 0 }

        chart_data = { data_1: [{ name: "Physical", data: p_1 }, { name: "Digital", data: d_1 }],
                   data_2: [{ name: "Physical", data: p_2 }, { name: "Digital", data: d_2 }],
                   p_labels_1: p_labels_1,
                   p_labels_2: p_labels_2,
                   d_labels_1: d_labels_1,
                   d_labels_2: d_labels_2,
                   height_1: 7 + 31 + 32 + sep * 20,
                   height_2: 7 + 31 + 32 + (num_of_devs - sep) * 20,
                   max: max
                 }
      else
        sql ="""SELECT developers.name
                FROM collection_games
                LEFT JOIN developer_games ON collection_games.game_id=developer_games.game_id
                LEFT JOIN developers ON developer_games.developer_id=developers.id
                WHERE collection_id='#{@collection.id}'
                ORDER BY developers.name ASC;"""

        r = ActiveRecord::Base.connection.execute(sql).values.flatten

        data = []
        dominant = ['', 0]
        values = []

        r.map! { |e| e.nil? ? '~~~' : e } if r.include?(nil)

        r.uniq.each do |d|
          val = r.count(d)
          values << val
          d = d[0...31] + '...' if d.size >= 35
          data << [d, val]
          dominant = [d, val] if val > dominant.last
        end

        if data.last && data.last[0] == '~~~'
          data.last[0] = '(no data)'
        end

        dominant[0] = '(no data)' if dominant[0] == '~~~'

        set_developer_stat(dominant)

        num_of_devs = data.size
        sep = (num_of_devs / 2.0).round
        max = values.max

        limit = (max * 0.08).round unless values.empty?
        labels = data.map { |g| g[1] >= limit && g[1] != 0 }

        chart_data = { data_1: data.slice(0...sep),
                   data_2: data.slice(sep..),
                   labels_1: labels.slice(0...sep),
                   labels_2: labels.slice(sep..),
                   height_1: 7 + 31 + 20 + sep * 20,
                   height_2: 7 + 31 + 20 + (num_of_devs - sep) * 20,
                   max: max}
      end
    end

    def set_developer_stat(dominant)
      @result[:stats] << (dominant[1] == 0 ? '-' : "#{dominant[0]} (#{dominant[1]})")
    end

    def last_game_stat
      @result[:stats] << (!@games.empty? ? @games.first.last : '-')
    end

    def round_to(a, const)
      res = (a / const) * const
      res += const if a % const > 0
      res
    end
end
