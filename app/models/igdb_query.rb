require 'net/https'

class IgdbQuery
  include ActiveModel::Validations
  attr_accessor :query
  attr_reader :results
  validates :query, presence: true

  @@limit = 50
  @@offset_limit = 150

  def initialize(query)
    @query = query
  end

  def request(offset = 0)
    http = Net::HTTP.new('api-v3.igdb.com', 80)
    request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/games'),
                                 'user-key' => ENV['IGDB_KEY'])
    # 1:
    request.body = "fields name, first_release_date; search #{@query.inspect};
                                                              limit #{@@limit};
                                                              offset #{offset};"
    first_bucket = JSON.parse http.request(request).body
    @first_size = first_bucket.size
    # 2:
    request.body  = "fields name, first_release_date;
      where name ~ #{@query.inspect}*; sort popularity desc; limit #{@@limit};
                                                              offset #{offset};"
    second_bucket = JSON.parse http.request(request).body
    @second_size = second_bucket.size
    # 1+2:
    @results = (first_bucket + second_bucket).uniq
  end

  def is_more?
    #make some constants for limits of using igdb!!!!
    if @first_size.nil?
      return nil
    elsif @first_size == @@limit || @second_size == @@limit
      return true
    else
      return false
    end
  end

  def get_more

  end

end
