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
        chart1.append [c.name, num_of_games]
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
      chart2.append ['No format', all_games - all_physical - all_digital]
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

    #Chart 1: Against the rest
    overall = 0

    Collection.where("user_id = ?", user_id).each do |c|
      overall += c.games.count
    end

    chart1 = [[self.name, num_of_games]]
    chart1.append ['Other collections', overall - num_of_games]

    if self.needs_platform
      #Chart 2: Physical games vs digital
      physical = games.count {|g| g[2] == true}
      chart2 = [['Physical', physical]]
      chart2.append ['Digital', num_of_games - physical]

      #Chart 3: Games per platform
      platforms = games.map(&:second)
      chart3 = []

      platforms.uniq.each do |p|
        chart3.append [p, platforms.count(p)]
      end
    else
      char2, chart3 = nil, nil
    end

    #Chart 4: Games per release year
    years = games.map { |g| Time.at(g.first).year }
    chart4 = []

    years.uniq.each do |y|
      chart4.append [y, years.count(y)]
    end

    #Chart 5: Developers
    sql = "SELECT developers.name FROM collection_games INNER JOIN developer_games ON collection_games.game_id=developer_games.game_id INNER JOIN developers ON developer_games.developer_id=developers.id WHERE collection_id='#{self.id}';"
    r = ActiveRecord::Base.connection.execute(sql).values.flatten.sort
    chart5 = r.inject(Hash.new(0)) {|hash, arr_element| hash[arr_element] += 1; hash }.to_a
    return chart1, chart2, chart3, chart4, chart5
  end
end
