class CollectionsController < ApplicationController
before_action :require_user, except: [:show_guest]
before_action :correct_user, only:
                    [:show, :edit, :update, :destroy,
                     :remove_game, :remove_game_search]
before_action :correct_guest, only: [:show_guest]

def show
  show_or_search(false, current_user.gpv)
end

def show_guest
  show_or_search(true, Collection::GAMES_PER_PAGE_SHARED)
end

def new
  @collection = Collection.new
  respond_to :js
end

def create
  collection = BuildNewCollection.call(user: current_user,
                                       data: collection_params)
  if collection.save
    respond_to :js
  else
    js_partial('error', { error: collection.errors.full_messages.first })
  end
end

def edit
  respond_to :js
end

def update
  if @collection.update(collection_params)
    respond_to :js
  else
    js_partial('error', { error: @collection.errors.full_messages.first })
  end
end

def change_order
  ChangeCollectionsOrder.call(user: current_user, new_order: params[:cord])
  respond_to :js
end

def del_form
  @coll_name, @coll_id  = params[:name], params[:id]
  respond_to :js
end

def destroy
  @collection.destroy
  respond_to :js
end

def remove_game
  @game = @collection.games.find_by_id(params[:game_id])
  @view = params[:view]
  if @game
    @collection.games.delete(@game)
    @message = NotifComposer::ComposeRemoveNotif.call(game: @game,
                                              collection: @collection)
    respond_to :js
  else
    js_partial('problem_msg')
  end
end

def remove_game_search
  @x_id = params[:x_id]
  if @game = @collection.games.find_by_id(params[:game_id])
    @collection.games.delete(@game)
    @message = NotifComposer::ComposeRemoveNotif.call(game: @game,
                                              collection: @collection)
    @remove_underline = !CheckIfUserHasGame.call(user: current_user,
                                                igdb_id: @game.igdb_id)
    respond_to :js
  else
    js_partial('problem_msg')
  end
end

private
  def show_or_search(shared, per_page)
    q = params[:q]
    @q = @collection.games.ransack(q)
    cookie = shared ? 'shared_view' : 'my_view'
    @view = params[:gsview] || cookies[cookie] || 'covers'
    @games = @q.result
      .group('games.id, collection_games.created_at')
      .includes(:developers)
      .paginate(page: params[:page], per_page: per_page)
    unless q
      cookies['last'] = { value: params[:id], expires: 30.days } unless shared
      prepare_reopen if @view == 'panels'
      js_partial('show', { shared: shared })
    else
      query = [q[:name_dev_cont], q[:plat_eq], q[:physical_eq]]
      query.map! { |a| a ||= '' }
      @in_search = !(q.keys == ['s'] || q.values.join == 'on')
      prepare_reopen if @view == 'panels'
      js_partial('search', { query: query, sort: q[:s], shared: shared })
    end
  end

  def prepare_reopen
      @reopen = params[:reopen] || []
      @reopen.map!(&:to_i)
      params.delete :reopen
  end

  def collection_params
    params.require(:collection).permit(:name, :needs_platform)
  end

  def correct_user
    @collection = current_user.collections.find_by_id(params[:id])
    reload if @collection.nil?
  end

  def correct_guest
    @collection = shared_collections.find_by_id(params[:id])
    redirect_to root_url if @collection.nil?
  end
end
