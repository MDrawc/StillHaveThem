class StaticPagesController < ApplicationController
  before_action :require_user, only: [:search_page]
  # For duplicates removal:
  @@last_result_ids = []

  def home
    if logged_in?
      if (last = cookies["#{ current_user.id }-last"]).present?
        case last
        when 'search'
        else
          @home_id = last
        end
      else
        @home_id = current_user.collections.first.id if !current_user.collections.empty?
      end
    end
  end

  def privacy
  end

  def terms
  end

  def about
  end

  def search_page
    respond_to :js
  end

  def search
    if params[:search] #First time search:
      @inquiry = IgdbQuery.new(params[:search])

      if @inquiry.validate!
        @inquiry.search
        if @inquiry.results.present?
          @@last_result_ids = @inquiry.results.map { |game| game[:igdb_id] }
          @owned = owned(@inquiry.results)
        end
      end

      respond_to do |format|
        format.js { render partial: "quest" }
      end

    elsif params[:last_form] #Load more:
      @inquiry = IgdbQuery.new(eval(params[:last_form]),
                 params[:last_offset].to_i + IgdbQuery::RESULT_LIMIT,
                 eval(params[:last_query]))

      @inquiry.search
      @inquiry.fix_duplicates(@@last_result_ids) if @inquiry.query_type == :game

      if @inquiry.results.present?
        @@last_result_ids += @inquiry.results.map { |game| game[:igdb_id] }
        @owned = owned(@inquiry.results)
      end

      respond_to do |format|
        format.js { render partial: "load_more" }
      end
    end
  end

  private

    def owned(results)
      res = []
      igdb_ids = results.map { |g| g[:igdb_id] }
      current_user.collections.each do |c|
        res += c.games.where(igdb_id: igdb_ids).pluck(:igdb_id)
      end
      return res.uniq
    end
end
