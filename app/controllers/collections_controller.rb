class CollectionsController < ApplicationController
before_action :require_user, except: [:show_guest]
before_action :correct_user, only: [:show, :edit, :update, :destroy]
before_action :correct_guest, only: [:show_guest]
before_action :correct_user_for_rm, only: [:remove_game, :remove_game_search]

PER_PAGE = 30

def new
  @collection = Collection.new
  respond_to :js
end

def show
  show_or_search(false)
end

def show_guest
  show_or_search(true)
end

def create
  @collection = current_user.collections.build(collection_params)
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

def destroy
  @collection.destroy
  respond_to :js
end

def remove_game
  @game = @collection.games.find_by_id(params[:game_id])
  @view = params[:view]
  @success = false

  if @game
    @collection.games.delete(@game)
    @message = "<span class='b'>Removed</span> #{@game.name} "
    if @collection.needs_platform
      @message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
    end
    @message += "from " + coll_link(@collection)
    @success = true
  else
    @message = "Game <span class='b'>does not belong</span> to " + coll_link(@collection)
  end
  respond_to :js
end

def remove_game_search
  @x_id = params[:x_id]
  @success = false

  if @game = @collection.games.find_by_id(params[:game_id])
    @collection.games.delete(@game)
    @message = "<span class='b'>Removed</span> #{@game.name} "
    if @collection.needs_platform
      @message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
    end
    @message += "from " + coll_link(@collection)
    @success = true

    @remove_underline = !owned?(@game.igdb_id)
  else
    @message = "Game <span class='b'>does not belong</span> to " + coll_link(@collection)
  end
  respond_to :js
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
    if @collection.nil?
      reload
    end
  end

  def correct_guest
    @collection = shared_collections.find_by_id(params[:id])
    if @collection.nil?
      reload
    end
  end

  def correct_user_for_rm
    @collection = current_user.collections.find_by_id(params[:collection_id])
    if @collection.nil?
      reload
    end
  end

  def owned?(igdb_id)
    results = []
    current_user.collections.each do |collection|
      results << collection.games.any? { |game| game.igdb_id == igdb_id }
    end
    return results.any?
  end

  def show_or_search(shared)
    @q = @collection.games.ransack(params[:q])
    @view = params[:view] || cookies['my_view'] || 'covers'
    unless params[:q]
      @games = @collection.games.paginate(page: params[:page], per_page: PER_PAGE)
      @refresh = params[:type] == 'refresh'
      cookies['last'] = { value: params[:id], expires: 30.days }

      respond_to do |format|
        format.js { render partial: "show", locals: { shared: shared } }
      end
    else
      @in_search = true
      @games = @q.result
      .group('games.id, collection_games.created_at')
      .includes(:developers)
      .paginate(page: params[:page], per_page: PER_PAGE)

      q = params[:q]
      query = [q[:name_dev_cont], q[:plat_eq], q[:physical_eq]]
      query.map! { |a| a ||= '' }
      sort = q[:s]
      respond_to do |format|
        format.js { render partial: "search",
          locals: { query: query, sort: sort, shared: shared }
        }
      end
    end
  end
end
