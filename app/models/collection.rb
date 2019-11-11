class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_games, dependent: :destroy
  has_many :games, through: :collection_games
  default_scope { order(created_at: :asc) }
  validates :user_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :user_id,
    message: "is used by another collection", case_sensitive: false }, length: { maximum: 50 }

  def is_shared?()
    !user.shares.where('? = ANY(shared)', id).empty?
  end

  def self.data_for_overall_graphs(obj)

      shared = obj.class.name == 'Share'

      chart_1, chart_2 = [], []

      #Stats:
      stats = []
      stats[0] = obj.created_at.to_f * 1000

      unless shared
        where_part = "WHERE collections.user_id='#{ obj.id }'"
        collections = obj.collections.pluck(:name)
      else
        where_part = "WHERE collections.id IN (#{ obj.shared.join(', ') })"
        collections = Collection.where(id: obj.shared).pluck(:name)
      end

      sql = """SELECT collections.name, games.first_release_date, games.platform_name, games.physical, games.name, collection_games.created_at
               FROM collections
               INNER JOIN collection_games ON collections.id = collection_games.collection_id
               INNER JOIN games ON collection_games.game_id = games.id
               #{ where_part }
               ORDER BY collection_games.created_at DESC;"""

      games = ActiveRecord::Base.connection.execute(sql).values

      #Stats:
      stats[1] = all_games = games.size
      stats[6] = (!games.empty? ? games.first[4] : '-')

      #Chart 1: Games by format
      physical = games.count { |g| g[3] }
      digital = games.count { |g| g[3] == false }
      not_defined = all_games - physical - digital
      chart_1 = { 'Physical' => physical,
               'Digital' => digital,
               'Not defined' => not_defined }

      #Stats:
      max = chart_1.values.max
      count = chart_1.values.count(max)

      if count == 1
        stats[3] = chart_1.key(max) + " (#{ max })"
      else
        res = ''
        chart_1.each { |k,v| res += (k + '-') if v == max }
        stats[3] = "tie #{ res[0...-1] } (#{ max })".downcase
      end

      #Chart 2: Games by collection
      coll_data = games.map(&:first)

      largest = ['', 0]
      data = []
      collections.each do |c|
        val = coll_data.count(c)
        largest = [c, val] if val > largest.last
        data << [c, val]
      end

      #Stats:
      stats[2] = (games.empty? ? '-' : "#{largest[0]} (#{largest[1]})")

      height = 2*15 + 2*8 + data.size*(15 + 8) - 7
      height = 600 if height > 600
      height = 250 if height < 250

      chart_2 = { data: data, height: height }

      #Chart 3: Games by platform
      data = []
      plat_data = games.map { |g| g[2].nil? ? '~~~' : g[2] }

      platforms = plat_data.uniq.sort

      dominant = ['', 0]
      platforms.each do |p|
        val = plat_data.count(p)
        dominant = [p, val] if val > dominant.last
        data << [p, val]
      end

      data.last[0] = 'Not defined' if !data.empty? && data.last[0] == '~~~'
      dominant[0] = 'Not defined' if dominant[0] == '~~~'

      height = 2*15 + 2*8 + data.size*(15 + 8) - 7
      height = 600 if height > 600
      height = 250 if height < 250

      chart_3 = { data: data, height: height }

      #Stats:
      stats[4] = (games.empty? ? '-' : "#{dominant[0]} (#{dominant[1]})")

      #Chart 4: Games by release year
      p_years, d_years, nd_years = [],[],[]
      games.each do |g|
        if g[3]
          p_years << Time.at(g.second).year
        elsif g[3] == false
          d_years << Time.at(g.second).year
        else
          nd_years << Time.at(g.second).year
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

      unless total_values.empty?
        max = total_values.max
        chrt_max = round_to(max, 5)
        limit = (chrt_max * 0.08).round
        p_labels = datasets[0][:data].map { |g| g[1] >= limit && g[1] != 0 }
        d_labels = datasets[1][:data].map { |g| g[1] >= limit && g[1] != 0 }
        nd_labels = datasets[2][:data].map { |g| g[1] >= limit && g[1] != 0 }
      end

      chart_4 = { data: datasets,
                  p_labels: p_labels,
                  d_labels: d_labels,
                  nd_labels: nd_labels,
                  max: chrt_max }

      #Chart 5: Games by developer
      sql = """SELECT developers.name, games.physical
               FROM collection_games
               INNER JOIN collections ON collection_games.collection_id = collections.id
               INNER JOIN developer_games ON collection_games.game_id=developer_games.game_id
               INNER JOIN developers ON developer_games.developer_id=developers.id
               INNER JOIN games ON collection_games.game_id = games.id
               #{ where_part };"""

      r = ActiveRecord::Base.connection.execute(sql).values

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

      #Stats:
      stats[5] = (dominant[1] == 0 ? '-' : "#{dominant[0]} (#{dominant[1]})")

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

      chart_5 = { data_1: [{ name: "Physical", data: p_1 },
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

      return {
         stats: stats,
         chart_1: chart_1,
         chart_2: chart_2,
         chart_3: chart_3,
         chart_4: chart_4,
         chart_5: chart_5
      }
  end

  def data_for_graphs
    games = self.games.pluck(:first_release_date, :platform_name, :physical, :name)
    num_of_games = games.size
    user_id = self.user_id

    #Stats:
    stats = []
    stats << created_at.to_f * 1000
    stats << (needs_platform ? 'yes' : 'no')
    stats << num_of_games

    #Chart 1: Against the rest

    sql = """SELECT COUNT(collections.id)
             FROM collections
             INNER JOIN collection_games ON collections.id = collection_games.collection_id
             WHERE collections.user_id = '#{user_id}';"""

    overall = ActiveRecord::Base.connection.execute(sql).values[0][0]

    chart_1 = [[self.name, num_of_games]]
    chart_1 << ['Other collections', overall - num_of_games]

    if self.needs_platform

      #Chart 2: Games by format
      physical = games.count {|g| g[2] == true}
      digital = num_of_games - physical
      chart_2 = [['Physical', physical]]
      chart_2 << ['Digital', digital]

      #Stats:
      if physical > digital
        stats << "physical (#{physical})"
      elsif games.empty?
        stats << '-'
        chart_2 = nil
      elsif physical == digital
        stats << "tie (physical: #{physical}, digital: #{digital})"
      else
        stats << "digital (#{digital})"
      end

      #Chart 3: Games per platform
      data = []
      platforms = games.map(&:second)

      dominant = ['', 0]
      platforms.uniq.sort.each do |p|
        val = platforms.count(p)
        dominant = [p, val] if val > dominant.last
        data << [p, val]
      end

      height = 2*15 + 2*8 + data.size*(15 + 8) - 7
      height = 600 if height > 600
      height = 250 if height < 250

      chart_3 = { data: data, height: height }

      #Stats:
      stats << (games.empty? ? '-' : "#{dominant[0]} (#{dominant[1]})")

    else

      #Stats:
      stats << '-'
      stats << '-'

      char_2, chart_3 = nil, nil
    end

    #Chart 4: Games per release year
    if self.needs_platform
      p_years, d_years = [],[]
      games.each do |g|
        if g[2]
          p_years << Time.at(g.first).year
        else
          d_years << Time.at(g.first).year
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

      unless total_values.empty?
        max = total_values.max
        chrt_max = round_to(max, 5)
        limit = (chrt_max * 0.08).round
        p_labels = datasets[0][:data].map { |g| g[1] >= limit && g[1] != 0 }
        d_labels = datasets[1][:data].map { |g| g[1] >= limit && g[1] != 0 }
      end

      chart_4 = { data: datasets, p_labels: p_labels, d_labels: d_labels, max: chrt_max }
    else

      years = games.map { |g| Time.at(g.first).year }
      data = []
      values = []
      years.uniq.sort.each do |y|
        val = years.count(y)
        data << [y, val]
        values << val
      end

      unless values.empty?
        max = values.max
        chrt_max = round_to(max, 5)
        limit = (chrt_max * 0.08).round
        labels = data.map { |g| g[1] >= limit && g[1] != 0 }
      end

      chart_4 = { data: data, labels: labels, max: chrt_max }
    end

    #Chart 5: Developerss
    if self.needs_platform

      sql = """SELECT developers.name, games.physical
               FROM collection_games
               INNER JOIN developer_games ON collection_games.game_id=developer_games.game_id
               INNER JOIN developers ON developer_games.developer_id=developers.id
               INNER JOIN games ON collection_games.game_id = games.id
               WHERE collection_id = '#{self.id}';"""

      r = ActiveRecord::Base.connection.execute(sql).values

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

      #Stats:
      stats << (dominant[1] == 0 ? '-' : "#{dominant[0]} (#{dominant[1]})")

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

      chart_5 = { data_1: [{ name: "Physical", data: p_1 }, { name: "Digital", data: d_1 }],
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
              INNER JOIN developer_games ON collection_games.game_id=developer_games.game_id
              INNER JOIN developers ON developer_games.developer_id=developers.id
              WHERE collection_id='#{self.id}'
              ORDER BY developers.name ASC;"""

      r = ActiveRecord::Base.connection.execute(sql).values.flatten

      data = []
      dominant = ['', 0]
      values = []
      r.uniq.each do |d|
        val = r.count(d)
        values << val
        d = d[0...31] + '...' if d.size >= 35
        data << [d, val]
        dominant = [d, val] if val > dominant.last
      end

      #Stats:
      stats << (dominant[1] == 0 ? '-' : "#{dominant[0]} (#{dominant[1]})")

      num_of_devs = data.size
      sep = (num_of_devs / 2.0).round
      max = values.max

      limit = (max * 0.08).round unless values.empty?
      labels = data.map { |g| g[1] >= limit && g[1] != 0 }

      chart_5 = { data_1: data.slice(0...sep),
                 data_2: data.slice(sep..),
                 labels_1: labels.slice(0...sep),
                 labels_2: labels.slice(sep..),
                 height_1: 7 + 31 + 20 + sep * 20,
                 height_2: 7 + 31 + 20 + (num_of_devs - sep) * 20,
                 max: max}
    end

    #Stats:
    stats << (!games.empty? ? games.first.last : '-')

    return {
             stats: stats,
             chart_1: chart_1,
             chart_2: chart_2,
             chart_3: chart_3,
             chart_4: chart_4,
             chart_5: chart_5
           }
  end

private

  def self.round_to(a, const)
    res = (a / const) * const
    res += const if a % const > 0
    res
  end

  def round_to(a, const)
    res = (a / const) * const
    res += const if a % const > 0
    res
  end
end
