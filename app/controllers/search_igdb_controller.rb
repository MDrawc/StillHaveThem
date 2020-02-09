class SearchIgdbController < ApplicationController
  before_action :require_user, only: [:search]
  @@last_result_ids = []

  def search
    view = params[:view] || cookies['s_view'] || 'cover_view'
    if (search_params = params[:search])
      @inquiry = SearchIgdb.new(search_params)
      if @inquiry.validate!
        @inquiry.search
        results_size = @inquiry.results.size
        CreateHistoryRecord.call(user: current_user,
                                 search_params: search_params,
                                 results_size: results_size)
        unless results_size.zero?
          @results = @inquiry.results
          @@last_result_ids = @results.pluck(:igdb_id)
          @owned = FindOwnedGames.call(user: current_user, results: @results)
        end
        @history_records = current_user.records
        js_partial('search', { view: view })
      else
        js_partial('error', { message: @inquiry.error_msg })
      end
    elsif params[:last_form]



      last_form = JSON.parse params[:last_form].gsub('=>', ':') unless params[:last_form].empty?
      last_query = JSON.parse params[:last_query].gsub('=>', ':')

      new_offset = params[:last_offset].to_i + SearchIgdb::RESULT_LIMIT
      @inquiry = SearchIgdb.new(last_form, new_offset, last_query)






      @inquiry.search

      @inquiry.fix_duplicates(@@last_result_ids) if @inquiry.query_type == :game

      if @inquiry.results.present?
        @results = @inquiry.results
        @@last_result_ids += @results.pluck(:igdb_id)
        @owned = FindOwnedGames.call(user: current_user, results: @results)
      end





      js_partial('load_more', { view: view })
    end
  end

  private
  def first_search
  end

  def load_more
  end

  def prepare_results()
  end
end
