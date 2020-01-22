class CollectionsController < ApplicationController
before_action :require_user, except: [:show_guest]
before_action :correct_user, only: [:show, :edit, :update, :destroy]
before_action :correct_guest, only: [:show_guest]
before_action :correct_user_for_rm, only: [:remove_game, :remove_game_search]

PER_PAGE_SH = 30

def new
  @collection = Collection.new
  respond_to :js
end

def show
  show_or_search(false, current_user.gpv)
end

def show_guest
  show_or_search(true, PER_PAGE_SH)
end

def create

  if (last_coll = current_user.collections.last)
    cord = last_coll.cord + 1
  else
    cord = 1
  end

  @collection = current_user.collections.build(collection_params)
  @collection.cord = cord

  @errors = nil

  if @collection.save
    respond_to :js
  else
    @error = @collection.errors.full_messages.first
    respond_to do |format|
        format.js { render partial: "error" }
    end
  end
end

def edit
  respond_to :js
end

def change_order
  cord = params[:cord]
  current_user.collections.each do |c|
    c.update(cord: cord[c.id.to_s]) if cord.keys.include?(c.id.to_s)
  end
  respond_to :js
end

def update
  if @collection.update(collection_params)
    respond_to :js
  else
    @error = @collection.errors.full_messages.first
    respond_to do |format|
        format.js { render partial: "error" }
    end
  end
end

def del_form
  @coll_name = params[:name]
  @coll_id = params[:id]
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
    @message = "<span class='b'>Removed</span> #{@game.name} "
    if @collection.needs_platform
      @message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
    end
    @message += "from " + coll_link(@collection)
    respond_to :js
  else
    @message = "Game <span class='b'>does not belong</span> to " + coll_link(@collection)
    respond_to do |format|
        format.js { render partial: "problem_msg.js" }
    end
  end
end

def remove_game_search
  @x_id = params[:x_id]

  if @game = @collection.games.find_by_id(params[:game_id])
    @collection.games.delete(@game)
    @message = "<span class='b'>Removed</span> #{@game.name} "
    if @collection.needs_platform
      @message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
    end
    @message += "from " + coll_link(@collection)

    @remove_underline = !owned?(@game.igdb_id)
    respond_to :js
  else
    @message = "Game <span class='b'>does not belong</span> to " + coll_link(@collection)
    respond_to do |format|
        format.js { render partial: "problem_msg.js" }
    end
  end
end

private

  def collection_params
    params.require(:collection).permit(:name,
     :needs_platform)
  end

  def coll_link(collection)
    "<a class='c' data-remote='true' href='#{ collection_path(collection) }' >#{ collection.name }</a>"
  end

  def correct_user
    @collection = current_user.collections.find_by(id: params[:id])
    reload if @collection.nil?
  end

  def correct_guest
    @collection = shared_collections.find_by_id(params[:id])
    redirect_to root_url if @collection.nil?
  end

  def correct_user_for_rm
    @collection = current_user.collections.find_by_id(params[:collection_id])
    reload if @collection.nil?
  end

  def owned?(igdb_id)
    results = []
    current_user.collections.each do |collection|
      results << collection.games.any? { |game| game.igdb_id == igdb_id }
    end
    return results.any?
  end

  def show_or_search(shared, per_page)
    @q = @collection.games.ransack(params[:q])
    cookie = shared ? 'shared_view' : 'my_view'
    @view = params[:gsview] || cookies[cookie] || 'covers'

    @games = @q.result
      .group('games.id, collection_games.created_at')
      .includes(:developers)
      .paginate(page: params[:page], per_page: per_page)

    unless params[:q]
      cookies['last'] = { value: params[:id], expires: 30.days } unless shared

      @reopen = params[:reopen] || []
      @reopen.map!(&:to_i)
      params.delete :reopen

      respond_to do |format|
        format.js { render partial: "show", locals: { shared: shared } }
      end
    else
      q = params[:q]
      query = [q[:name_dev_cont], q[:plat_eq], q[:physical_eq]]
      query.map! { |a| a ||= '' }
      sort = q[:s]
      @in_search = !(q.keys == ['s'] || q.values.join == 'on')

      @reopen = params[:reopen] || []
      @reopen.map!(&:to_i)
      params.delete :reopen

      respond_to do |format|
        format.js { render partial: "search",
          locals: { query: query, sort: sort, shared: shared }
        }
      end
    end
  end
end
