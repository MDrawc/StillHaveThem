class ChartsController < ApplicationController
  before_action :require_user, only: [:form, :graphs]
  before_action :require_guest, only: [:guest_form, :graphs_for_guest]

  def form
    @coll_id = params[:id]
    js_partial('form', { url: '/graphs', user: current_user })
  end

  def guest_form
    @coll_id = params[:id]
    js_partial('form', { url: '/g_graphs', user: guest })
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
      reload
    end
    js_partial('graphs', { shared: false })
  end

  def graphs_for_guest
    @overall, @needs_platform = false, false
    if params[:graph_collection] == 'all'
      @charts_data = Collection.data_for_overall_graphs(guest)
      @overall = true
    elsif guest.shared.include?(params[:graph_collection].to_i)
      if coll = Collection.find_by_id(params[:graph_collection])
        @charts_data = coll.data_for_graphs
        @needs_platform = coll.needs_platform
      else
        reload
      end
    else
      reload
    end
    js_partial('graphs', { shared: true })
  end
end
