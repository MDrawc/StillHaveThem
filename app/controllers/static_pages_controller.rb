class StaticPagesController < ApplicationController
  before_action :require_user, only: [:search_page, :search]
  LIMIT = 50
  # For duplicates removal:
  @@last_result_ids = []
  # For more games than limit (mainly developers search)
  @@more = []
  # For new offset request:
  @@new_offset_r = {}
  # For status:
  @@status = nil

  def home
    if logged_in?
      if (last = cookies['last']).present?
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

  def search_page
    @records = current_user.records
    respond_to :js
  end

  def search
    @more_in_req, @more_in_off = false
    view = params[:view] || cookies['s_view'] || 'cover_view'

    #SEARCH
    if params[:search]

      @inquiry = IgdbQuery.new(params[:search])
      search_record = build_record(params[:search])
      if @inquiry.validate!
        @inquiry.search

        search_record.results = @inquiry.results.size
        search_record.save
        if @inquiry.results.present?
          #Prepare data for fix_duplicates with new offset request:
          @@last_result_ids = @inquiry.results.map { |game| game[:igdb_id] }
          #Check owned games for underlining them in view:
          @owned = owned(@inquiry.results)
          #Save status
          @@status = @inquiry.status_id
          #Get status
          @status = @@status
          #Check if there is new offset request:
          if @inquiry.is_more?
            @@new_offset_r[:last_form] = @inquiry.last_form
            @@new_offset_r[:query] = @inquiry.query
            @@new_offset_r[:offset] = @inquiry.offset
            @more_in_off = @@new_offset_r
          else
            @@new_offset_r = {}
          end
          @results = @inquiry.results
          #Slice results if games is more than LIMIT:
          unless @inquiry.query_type == :game
            if @results.size > LIMIT
              @@more = @results.slice!(LIMIT...)
              @more_in_req = true
            end
          end
        end
      end

      @records = current_user.records

      respond_to do |format|
        format.js { render partial: "quest", locals: { user_id: current_user.id, view: view } }
      end

    #LOAD MORE - more games in new offset request:
    elsif params[:last_form]
      @inquiry = IgdbQuery.new(eval(params[:last_form]),
                 params[:last_offset].to_i + IgdbQuery::RESULT_LIMIT,
                 eval(params[:last_query]))

      @inquiry.search
      #Fixing duplicates
      @inquiry.fix_duplicates(@@last_result_ids) if @inquiry.query_type == :game

      if @inquiry.results.present?
        #Prepare data for fix_duplicates with new offset request:
        @@last_result_ids += @inquiry.results.map { |game| game[:igdb_id] }
        #Check owned games for underlining them in view:
        @owned = owned(@inquiry.results)

        #Save status
        @@status = @inquiry.status_id
        #Get status
        @status = @@status

        #Check if there is new offset request:
        if @inquiry.is_more?
          @@new_offset_r[:last_form] = @inquiry.last_form
          @@new_offset_r[:query] = @inquiry.query
          @@new_offset_r[:offset] = @inquiry.offset
          @more_in_off = @@new_offset_r
        else
          @@new_offset_r = {}
        end
        @results = @inquiry.results
        #Slice results if games is more than LIMIT:
        unless @inquiry.query_type == :game
          if @results.size > LIMIT
            @@more = @results.slice!(LIMIT...)
            @more_in_req = true
          end
        end
      end
      respond_to do |format|
        format.js { render partial: "load_more", locals: { view: view } }
      end

    #LOAD MORE - more games in the same request(developers/characters):
    elsif params[:cut]
      @results = @@more.slice!(0...LIMIT)
      @more_in_req = !@@more.empty?
      @owned = owned(@results)
      #Get status
      @status = @@status
      @more_in_off = @@new_offset_r if !@@new_offset_r.empty?

      respond_to do |format|
        format.js { render partial: "load_more", locals: { view: view } }
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

    def build_record(s_par)

      f_values = s_par.values[2..]

      data = { inquiry: s_par[:inquiry].strip.downcase,
       query_type: s_par[:query_type],
       filters: f_values,
       custom_filters: !f_values.map {|f| f == '1'}.all? }

      record = current_user.records.build(data)
    end
end
