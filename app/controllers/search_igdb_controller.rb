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
        prepare_results(is_load_more: false) unless results_size.zero?
        @history_records = current_user.records
        js_partial('search', { view: view })
      else
        js_partial('error', { message: @inquiry.error_msg })
      end
    elsif (last_form = params[:last_form])
      last_form = string_to_hash(last_form) unless last_form.empty?
      last_query = string_to_hash(params[:last_query])
      new_offset = params[:last_offset].to_i + SearchIgdb::RESULT_LIMIT
      @inquiry = SearchIgdb.new(last_form, new_offset, last_query)
      @inquiry.search
      @inquiry.fix_duplicates(@@last_result_ids) if @inquiry.query_type == :game
      prepare_results(is_load_more: true) unless @inquiry.results.empty?
      js_partial('load_more', { view: view })
    end
  end

  private
  def prepare_results(is_load_more:)
    @results = @inquiry.results
    unless is_load_more
      @@last_result_ids = @results.pluck(:igdb_id)
    else
      @@last_result_ids += @results.pluck(:igdb_id)
    end
    @owned = FindOwnedGames.call(user: current_user, results: @results)
  end

  def string_to_hash(data)
    JSON.parse data.gsub('=>', ':')
  end
end
