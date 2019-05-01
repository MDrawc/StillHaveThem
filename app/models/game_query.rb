require 'net/https'

class GameQuery
  include ActiveModel::Validations
  attr_accessor :query
  validates :query, presence: true, length: { minimum: 1 }

  def initialize(query)
    @query = query
  end

  def results
    http = Net::HTTP.new('api-v3.igdb.com', 80)
    request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/games'), {'user-key' => ENV['IGDB_KEY'] })

    # 1:
    request.body = "fields name, first_release_date; search #{@query.inspect}; limit 50;"
    first_bucket = JSON.parse http.request(request).body
    first_size = first_bucket.size

    # 2:
    request.body  = "fields name, first_release_date; where name ~ #{@query.inspect}*; sort popularity desc; limit 50;"
    second_bucket = JSON.parse http.request(request).body
    second_size = second_bucket.size

    # 1+2:
    sum_bucket = first_bucket + second_bucket
    sum_bucket.uniq!
    sum_size = sum_bucket.size

    @results = sum_bucket
  end
end
