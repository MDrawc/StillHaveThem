class ChartsController < ApplicationController
  before_action :require_user

  def graph_form
    respond_to :js
  end

  def graphs
    if params[:collection] == 'all'
    elsif coll = current_user.collections.find_by_id(params[:collection])
      @data = coll.data_for_graphs
    else
      respond_to do |format|
        format.js {render js: 'location.reload();' }
      end
    end
    respond_to :js
  end

end
