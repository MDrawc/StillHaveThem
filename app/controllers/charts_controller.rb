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

  def graphs_for_user
    graphs(shared: false)
  end

  def graphs_for_guest
    graphs(shared: true)
  end

  private
    def graphs(shared:)
      @overall, @needs_platform = false, false
      if params[:graph_collection] == 'all'
        obj = shared ? guest : current_user
        @charts_data = GatherDataForOverallGraphs.call(obj: obj)
        @overall = true
      else
        if shared
          coll = Collection.find_by_id(params[:graph_collection])
        else
          coll = current_user.collections.find_by_id(params[:graph_collection])
        end

        if coll
          @charts_data = GatherDataForGraphs.call(collection: coll)
          @needs_platform = coll.needs_platform
        else
          reload
        end
      end
      js_partial('graphs', { shared: shared })
    end
end
