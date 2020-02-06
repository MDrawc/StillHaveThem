class SearchIgdbController < ApplicationController
  before_action :require_user, only: [:search]
  @@last_result_ids = []

  def search
    view = params[:view] || cookies['s_view'] || 'cover_view'
    #FIRST SEARCH
    if params[:search]
      @inquiry = IgdbQuery.new(params[:search])

      if @inquiry.validate!
        search_record = build_record(params[:search])
        @inquiry.search
        search_record.results = @inquiry.results.size
        search_record.save
        if @inquiry.results.present?
          #Prepare data to fix_duplicates with new offset request:
          @@last_result_ids = @inquiry.results.map { |game| game[:igdb_id] }
          #Check owned games for underlining them in view:
          @owned = owned(@inquiry.results)
          @results = @inquiry.results
        end

        @records = current_user.records

        respond_to do |format|
          format.js { render partial: "search", locals: { view: view } }
        end
      else
        respond_to do |format|
          format.js { render partial: "error", locals: { message: @inquiry.error_msg } }
        end
      end

    #LOAD MORE
    elsif params[:last_form]
      @inquiry = IgdbQuery.new(eval(params[:last_form]),
                 params[:last_offset].to_i + IgdbQuery::RESULT_LIMIT,
                 eval(params[:last_query]))

      @inquiry.search
      #Fixing duplicates
      @inquiry.fix_duplicates(@@last_result_ids) if @inquiry.query_type == :game

      if @inquiry.results.present?
        #Prepare data to fix_duplicates with new offset request:
        @@last_result_ids += @inquiry.results.map { |game| game[:igdb_id] }
        #Check owned games for underlining them in view:
        @owned = owned(@inquiry.results)
        @results = @inquiry.results
      end

      respond_to do |format|
        format.js { render partial: "load_more", locals: { view: view } }
      end
    end
  end

  private
    def owned(results)
      res = []
      igdb_ids = results.map { |g| g[:igdb_id] }
      current_user.collections.includes(:games).each do |c|
        res += c.games.where(igdb_id: igdb_ids).pluck(:igdb_id)
      end
      return res.uniq
    end

    def build_record(s_par)
      f_values = s_par.values[2..]

      data = { inquiry: s_par[:inquiry].strip.downcase,
       query_type: s_par[:query_type],
       filters: f_values,
       custom_filters: !f_values.map {|f| f == '1'}.all? }

      record = current_user.records.build(data)
    end
end
