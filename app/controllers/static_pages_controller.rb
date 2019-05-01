class StaticPagesController < ApplicationController

  def home
  end

  def about
  end

  def search
    if inquiry = params[:inquiry]

      http = Net::HTTP.new('api-v3.igdb.com', 80)
      request = Net::HTTP::Get.new(URI('https://api-v3.igdb.com/games'), {'user-key' => ENV['IGDB_KEY'] })

      # 1:
      request.body = "fields name, first_release_date; search #{inquiry.inspect}; limit 50;"
      first_bucket = JSON.parse http.request(request).body
      first_size = first_bucket.size

      # 2:
      request.body  = "fields name, first_release_date; where name ~ #{inquiry.inspect}*; sort popularity desc; limit 50;"
      second_bucket = JSON.parse http.request(request).body
      second_size = second_bucket.size

      # 1+2:`
      sum_bucket = first_bucket + second_bucket
      sum_bucket.uniq!
      sum_size = sum_bucket.size

      @search_results = sum_bucket

      respond_to do |format|
        format.js
      end
    end
  end
end
