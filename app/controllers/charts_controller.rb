class ChartsController < ApplicationController
  before_action :require_user

  def graph_form
    @coll_id = params[:id]
    respond_to :js
  end

  def graphs
    @overall, @needs_platform = false, false
    if params[:graph_collection] == 'all'
      @charts_data = Collection.data_for_overall_graphs(current_user)
      @overall = true
    elsif coll = current_user.collections.find_by_id(params[:graph_collection])
      @charts_data = coll.data_for_graphs
      @needs_platform = coll.needs_platform
    else
      respond_to do |format|
        format.js {render js: 'location.reload();' }
      end
    end
    respond_to :js
  end
end
