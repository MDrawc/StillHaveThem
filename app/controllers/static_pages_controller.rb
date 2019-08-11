class StaticPagesController < ApplicationController
  before_action :require_user, only: [:search]
  # For duplicates removal:
  @@last_result_ids = []

  def home
    @home_collection = current_user.collections.find_by(default: true) if logged_in?
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
          prepare_user_collections(current_user)
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
        prepare_user_collections(current_user)
      end

      respond_to do |format|
        format.js { render partial: "load_more" }
      end

    end
  end

  private
    def prepare_user_collections(user)
      @initial_collections = {}
      user.collections.initial.each do |collection|
        @initial_collections[collection.form] = collection
      end
      @custom_collections = user.collections.custom
    end
end
