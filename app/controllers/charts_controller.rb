class ChartsController < ApplicationController
  before_action :require_user

  def graph_form
    respond_to :js
  end

  def graphs
    if params[:collection] == 'all'
      @data = Collection.data_for_overall_graphs(current_user)
      @needs_platform = true
    elsif coll = current_user.collections.find_by_id(params[:collection])
      @data = coll.data_for_graphs
      @needs_platform = coll.needs_platform
    else
      respond_to do |format|
        format.js {render js: 'location.reload();' }
      end
    end
    respond_to :js
  end

end
