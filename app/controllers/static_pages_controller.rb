class StaticPagesController < ApplicationController
  before_action :require_user, only: [:search_page]
  LIMIT = 50
  # For duplicates removal:
  @@last_result_ids = []
  # For more games than limit (mainly developers search)
  @@more = []

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
    @more_in_req, @more_in_off = false, false
    #Search:
    if params[:search]
      @inquiry = IgdbQuery.new(params[:search])

      if @inquiry.validate!
        @inquiry.search
        if @inquiry.results.present?
          @@last_result_ids = @inquiry.results.map { |game| game[:igdb_id] }
          @owned = owned(@inquiry.results)

          if @inquiry.is_more?
            @more_in_off = true
          end

          @results = @inquiry.results
          unless @inquiry.query_type == :game
            if @results.size > LIMIT
              @@more = @results.slice!(LIMIT...)
              @more_in_req = true
            end
          end

        end
      end
      respond_to do |format|
        format.js { render partial: "quest" }
      end

    #Load more - more games in the same request(developers/characters):
    elsif params[:cut]
      @results = @@more.slice!(0...LIMIT)
      @more_in_req = !@@more.empty?
      @owned = owned(@results)
      respond_to do |format|
        format.js { render partial: "load_more" }
      end

    #Load more - more games in offset:
    elsif params[:last_form]
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
