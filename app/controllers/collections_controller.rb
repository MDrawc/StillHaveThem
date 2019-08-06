class CollectionsController < ApplicationController
before_action :require_user
before_action :correct_user, only: [:show, :edit, :update, :destroy]
before_action :never_those, only: [:destroy]

def new
  @collection = Collection.new
  respond_to :js
end

def show
  @games = @collection.games.paginate(page: params[:page], per_page: 12)
  @refresh = params[:type] == 'refresh'

  respond_to :js
end

def create
  @collection = current_user.collections.build(collection_params.except(:name))
  @collection.name = @collection.custom_name

  if @collection.save
    @message = "<span class='g'>Created</span> " + coll_link(@collection) + " collection"
  else
    @message = "<span class='b'>Could not</span> create collection"
  end
  respond_to :js
end

def edit
end

def update
  if @collection.update(collection_params)
    flash[:success] = 'Collection name changed'
    redirect_to root_url
  else
    render 'edit'
  end
end

def destroy
    @collection.destroy
    flash[:success] = "Collection deleted"
    redirect_to root_url
end

def remove_game
  @collection = current_user.collections.find_by_id(params[:collection_id])
  @game = @collection.games.find_by_id(params[:game_id])
  @success = false

  if @game
    @collection.games.delete(@game)

    #Notification:
    @message = "<span class='b'>Removed</span> #{@game.name} "
    if @collection.needs_platform
      @message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
    end
    @message += "from " + coll_link(@collection)

    @success = true
  else

    #Notification:
    @message = "Game <span class='b'>does not belong</span> to " + coll_link(@collection)
  end

  respond_to :js
end

def remove_game_search
  @collection = current_user.collections.find_by_id(params[:collection_id])
  @success = false

  if params[:id_type] == 'igdb'
    @game = @collection.games.find_by(igdb_id: params[:game_id])
  else
    @game = @collection.games.find_by_id(params[:game_id])
  end

  if @game
    @collection.games.delete(@game)

    #Prepare notification:
    @message = "<span class='b'>Removed</span> #{@game.name} "
    if @collection.needs_platform
      @message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
    end
    @message += "from " + coll_link(@collection)

    #Turn of underlight in My Collection
    if @collection.form == 'collection'
      @all_deleted = !@collection.games.igdb(@game.igdb_id).any?
    #Turn of underlight in Custom Collections
    elsif @collection.form == 'custom'
      @all_deleted = !check_for_game_in_custom(@game.igdb_id)
    end

    # Remove underline from removed game - coverview
    @remove_underline = !check_for_game_in_all(@game.igdb_id)

    @success = true
  else
    #Notification:
    @message = "Game <span class='b'>does not belong</span> to " + coll_link(@collection)
  end
  respond_to :js
end

private

  def collection_params
    params.require(:collection).permit(:name, :default, :custom_name,
     :needs_platform)
  end

  def coll_link(collection)
    "<a class='c' data-remote='true' href='#{ collection_path(collection) }' >#{ collection.called }</a>"
  end

  def correct_user
    @collection = current_user.collections.find_by(id: params[:id])
    redirect_to root_url if @collection.nil?
  end

  def never_those
    @collection = current_user.collections.find_by(id: params[:id])
    if @collection.initial
      flash[:danger] = "You can not delete this collection"
      redirect_to root_url
    end
  end

  def check_for_game_in_custom(igdb_id)
    results = []
    current_user.collections.custom.each do |collection|
      results << collection.games.any? { |game| game.igdb_id == igdb_id }
    end
    return results.any?
  end

  def check_for_game_in_all(igdb_id)
    results = []
    current_user.collections.each do |collection|
      results << collection.games.any? { |game| game.igdb_id == igdb_id }
    end
    return results.any?
  end
end
