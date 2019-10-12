class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_games, dependent: :destroy
  has_many :games, through: :collection_games
  default_scope { order(created_at: :asc) }
  validates :user_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :user_id,
    message: "is used by another collection", case_sensitive: false }, length: { maximum: 50 }


def data_for_graphs
  if self.needs_platform
    games = self.games.pluck(:first_release_date, :platform_name, :physical)

    chart1 = []
    total = games.size
    user_id = self.user_id
    overall = 0
    Collection.where("user_id = ?", user_id).each do |c|
      overall += c.games.count
    end
    chart1.append [self.name, total]
    chart1.append ['Other collections', overall]

    chart2 = []
    physical = games.count {|g| g[2] == true}
    chart2.append ['Physical', physical]
    chart2.append ['Digital', total - physical]

    chart3 = []
    platforms = games.map(&:second)
    platforms.uniq.each do |p|
      chart3.append [p, platforms.count(p)]
    end

    chart4 = []
    years = games.map { |g| Time.at(g.first).year }
    years.uniq.each do |y|
      chart4.append [y, years.count(y)]
    end

    return chart1, chart2, chart3, chart4
  else

  end
end

end
