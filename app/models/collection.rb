class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_games, dependent: :destroy
  has_many :games, through: :collection_games
  default_scope { order(created_at: :asc) }
  validates :user_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :user_id,
    message: "is used by another collection", case_sensitive: false }, length: { maximum: 50 }

  def self.data_for_overall_graphs(user_id)
      chart1, chart2 = [], []
      all_games = 0
      all_physical, all_digital = 0, 0
      all_platforms = Hash.new(0)
      all_years = Hash.new(0)

      no_platform = 0

      Collection.where("user_id = ?", user_id).each do |c|
        games = c.games.pluck(:first_release_date, :platform_name, :physical)

        num_of_games = games.size
        chart1 << [c.name, num_of_games]
        all_games += num_of_games

        if c.needs_platform
          physical = games.count {|g| g[2] == true}
          all_physical += physical
          all_digital += num_of_games - physical

          platforms = games.map(&:second)
          platforms.uniq.each do |p|
          all_platforms[p] += platforms.count(p)
          end
        else
          no_platform += num_of_games
        end

        years = games.map { |g| Time.at(g.first).year }
        years.uniq.each do |y|
        all_years[y] += years.count(y)
        end
      end

      chart2 = [['Physical', all_physical], ['Digital', all_digital]]
      chart2 << ['Not defined', all_games - all_physical - all_digital]
      all_platforms['No platform'] = no_platform
      chart3 = all_platforms.to_a
      chart4 = all_years.to_a

      #Chart 5: Developers
      coll_ids = User.find(1).collection_ids.join(', ')
      sql = "SELECT developers.name FROM collection_games INNER JOIN developer_games ON collection_games.game_id=developer_games.game_id INNER JOIN developers ON developer_games.developer_id=developers.id WHERE collection_id IN (#{coll_ids});"
      r = ActiveRecord::Base.connection.execute(sql).values.flatten.sort
      chart5 = r.inject(Hash.new(0)) {|hash, arr_element| hash[arr_element] += 1; hash }.to_a

      return chart1, chart2, chart3, chart4, chart5
  end

  def data_for_graphs
    games = self.games.pluck(:first_release_date, :platform_name, :physical)
    num_of_games = games.size
    user_id = self.user_id

    #Stats



    #Chart 1: Against the rest
    overall = 0

    Collection.where("user_id = ?", user_id).each do |c|
      overall += c.games.count
    end

    chart1 = [[self.name, num_of_games]]
    chart1 << ['Other collections', overall - num_of_games]

    if self.needs_platform
      #Chart 2: Physical games vs digital
      physical = games.count {|g| g[2] == true}
      chart2 = [['Physical', physical]]
      chart2 << ['Digital', num_of_games - physical]

      #Chart 3: Games per platform
      platforms = games.map(&:second)
      chart3 = []

      platforms.uniq.each do |p|
        chart3 << [p, platforms.count(p)]
      end
    else
      char2, chart3 = nil, nil
    end

    #Chart 4: Games per release year
    if self.needs_platform
      p_years, d_years = [],[]
      games.each do |g|
        if g[2] == true
          p_years << Time.at(g.first).year
        else
          d_years << Time.at(g.first).year
        end
      end

      datasets = [ { name: "Physical", data: [] },
        { name: "Digital", data: [] }]

      all_years = p_years.union(d_years).sort
      counts = []

      all_years.each do |y|
        val = p_years.count(y), d_years.count(y)
        datasets[0][:data] << [y, val[0]]
        datasets[1][:data] << [y, val[1]]
        counts += val
      end

      limit = (counts.max * 0.08).round unless counts.empty?
      p_labels = datasets[0][:data].map { |g| g[1] >= limit && g[1] != 0 }
      d_labels = datasets[1][:data].map { |g| g[1] >= limit && g[1] != 0 }
      chart4 = { data: datasets, p_labels: p_labels, d_labels: d_labels }
    else
      years = games.map { |g| Time.at(g.first).year }
      data = []
      counts = []

      years.uniq.sort.each do |y|
        val = years.count(y)
        data << [y, val]
        counts << val
      end

      limit = (counts.max * 0.08).round unless counts.empty?
      labels = data.map { |g| g[1] >= limit && g[1] != 0 }
      chart4 = { data: data, labels: labels }
    end

    #Chart 5: Developerss
    if self.needs_platform
      sql = "SELECT developers.name, games.physical FROM collection_games INNER JOIN developer_games ON collection_games.game_id=developer_games.game_id INNER JOIN developers ON developer_games.developer_id=developers.id INNER JOIN games ON collection_games.game_id = games.id WHERE collection_id = '#{self.id}';"
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
      single_values = []

      all_devs.sort.each do |d|
        values = p_devs.count(d), d_devs.count(d)
        d = d[0...31] + '...' if d.size >= 35
        p_dataset << [d, values[0]]
        d_dataset << [d, values[1]]
        single_values += values
        total_values << values.sum
      end

      num_of_devs = all_devs.size
      sep = (num_of_devs / 2.0).round

      p_1 = p_dataset.slice(0...sep)
      p_2 = p_dataset.slice(sep..)
      d_1 = d_dataset.slice(0...sep)
      d_2 = d_dataset.slice(sep..)

      limit = (single_values.max * 0.04).round unless counts.empty?
      p_labels_1 = p_1.map { |g| g[1] > limit && g[1] != 0 }
      p_labels_2 = p_2.map { |g| g[1] > limit && g[1] != 0 }
      d_labels_1 = d_1.map { |g| g[1] > limit && g[1] != 0 }
      d_labels_2 = d_2.map { |g| g[1] > limit && g[1] != 0 }

      chart5 = { data_1: [{ name: "Physical", data: p_1 }, { name: "Digital", data: d_1 }],
                 data_2: [{ name: "Physical", data: p_2 }, { name: "Digital", data: d_2 }],
                 p_labels_1: p_labels_1,
                 p_labels_2: p_labels_2,
                 d_labels_1: d_labels_1,
                 d_labels_2: d_labels_2,
                 height_1: 7 + 31 + 32 + sep * 20,
                 height_2: 7 + 31 + 32 + (num_of_devs - sep) * 20,
                 max: total_values.max
               }
    else
      sql ="SELECT developers.name FROM collection_games INNER JOIN developer_games ON collection_games.game_id=developer_games.game_id INNER JOIN developers ON developer_games.developer_id=developers.id WHERE collection_id='#{self.id}' ORDER BY developers.name ASC;"
      r = ActiveRecord::Base.connection.execute(sql).values.flatten

      data = []
      r.uniq.each do |d|
        val = r.count(d)
        d = d[0...31] + '...' if d.size >= 35
        data << [d, val]
      end

      num_of_devs = data.size
      sep = (num_of_devs / 2.0).round
      max = data.map(&:last).max

      limit = (counts.max * 0.08).round unless counts.empty?
      labels = data.map { |g| g[1] >= limit && g[1] != 0 }

      chart5 = { data_1: data.slice(0...sep),
                 data_2: data.slice(sep..),
                 labels_1: labels.slice(0...sep),
                 labels_2: labels.slice(sep..),
                 height_1: 7 + 31 + 20 + sep * 20,
                 height_2: 7 + 31 + 20 + (num_of_devs - sep) * 20,
                 max: max}
    end

    return chart1, chart2, chart3, chart4, chart5
  end
end
