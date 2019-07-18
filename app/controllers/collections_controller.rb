class CollectionsController < ApplicationController
before_action :require_user
before_action :correct_user, only: [:show, :edit, :update, :destroy]
before_action :never_those, only: [:destroy]

def new
  @collection = Collection.new

  respond_to do |format|
    format.js
  end
end

def show
  respond_to do |format|
    format.js
  end
end

def create
  @collection = current_user.collections.build(collection_params.except(:name))
  @collection.name = @collection.custom_name

  if @collection.save
    flash[:success] = "Collection created"
    redirect_to root_url
  else
    render 'new'
  end
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
  if @collection.games.delete(@game)
    flash[:danger] = "Deleted \"#{@game.name}\" from \"#{ @collection.custom_name || @collection.name }\""
    redirect_to root_url
  else
    flash[:danger] = "You cant delete this game"
  end
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
    collection_link = "<a class='c' href='#{collection_url(@collection)}'>#{ @collection.custom_name || @collection.name }</a>"
    @message = "<span class='b'>Removed</span> #{@game.name} "
    if @collection.needs_platform
      @message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
    end
    @message += "from " + collection_link

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
    collection_link = "<a class='c' href='#{collection_url(@collection)}'>#{ @collection.custom_name || @collection.name }</a>"
    @message = "Game <span class='b'>does not belong</span> to " + collection_link
  end

  respond_to do |format|
    format.js
  end
end

def move_game
end

private

  def collection_params
    params.require(:collection).permit(:name, :default, :custom_name,
     :needs_platform)
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
