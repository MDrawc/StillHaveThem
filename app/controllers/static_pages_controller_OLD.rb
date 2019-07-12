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

  def search
    # First time search:


    if params[:search]

      @inquiry = IgdbQuery.new(params[:search])

      if @inquiry.validate!
        @inquiry.search
        @@last_result_ids = @inquiry.results.map { |game| game = game["id"] }

        prepare_user_collections(current_user) if @inquiry.results.present?

      end

      respond_to do |format|
        format.html
        format.js
      end









    # Load more:
    elsif params[:last_input]
      @inquiry = IgdbQuery.new(eval(params[:last_input]),
                 params[:last_offset].to_i + IgdbQuery::RESULT_LIMIT)
      @inquiry.search
      @inquiry.fix_duplicates(@@last_result_ids)
      @@last_result_ids += @inquiry.results.map { |game| game = game["id"] }

      prepare_user_collections(current_user) if @inquiry.results.present?

      respond_to do |format|
        format.js { render partial: "show_more" }
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
