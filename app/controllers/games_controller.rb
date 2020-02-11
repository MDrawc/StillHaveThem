class GamesController < ApplicationController
  before_action :require_user, except: [:cover_show, :list_show, :panel_show]
  before_action :find_game_and_collection, only: [:edit_form, :copy_form]
  before_action :find_collection, only: [:create]
  before_action :find_agame, only: [:list_show, :cover_show, :panel_show]
  before_action :get_view, only: [:edit, :copy_or_move, :edit_form, :copy_form]
  respond_to :js

  def new
    @game = Game.new()
    @x_id = params[:x_id]
    @owned = params[:owned] == 'true'
    @data = GetDataForGameAdding.call(x_id: @x_id)
  end

  def create
    @x_id = params['x_id']
    add_game = AddGame.new(user: current_user,
                            collection: @collection,
                            data: game_params)
    add_game.call
    @errors = add_game.errors
    @message = add_game.message
    @igdb_id = add_game.igdb_id
  end

  def edit
    edit_game = EditGame.new(user: current_user,
                        collection_id: params[:collection],
                        data: game_params)
    edit_game.call
    @errors = edit_game.errors
    if @errors.empty?
      @message = edit_game.message
      @game_id = edit_game.game_id
      @new_game_id = edit_game.new_game_id
      @new_platform = edit_game.platform_name
      @collection = edit_game.collection
    end
  end

  def copy_or_move
    @copy = params[:copy] == 'true'
    copy_game = CopyGame.new(user: current_user,
                        current_id: params[:current],
                        collection_info: params[:collection],
                        copy: @copy,
                        data: game_params)
    copy_game.call
    @errors = copy_game.errors
    if @errors.empty?
      @message = copy_game.message
      @new_platform = copy_game.platform_name
      @inside_current = copy_game.inside_current
      @current = copy_game.current
      @collection = copy_game.collection
    end
  end

  def edit_form
  end

  def copy_form
  end

  def list_show
    @hg_id = params[:hg_id]
  end

  def cover_show
  end

  def panel_show
    @g_id = params[:g_id]
  end

  private
    def game_params
      params.require(:game).permit(:id, :igdb_id, :collection, :needs_platform,
                                   :platform, :physical, :last_platform,
                                   :last_physical)
    end

    def find_collection
      coll_id = game_params[:collection].split(',').first.to_i
      @collection = current_user.collections.find_by_id(coll_id)
      reload if @collection.nil?
    end

    def find_game_and_collection
      @collection = current_user.collections.find_by_id(params[:collection_id])
      if @collection.nil?
        reload
      else
        @game = @collection.games.find_by_id(params[:game_id])
      end
    end

    def find_agame
      @game = Agame.find_by(igdb_id: params[:igdb_id])
    end

    def get_view
      @view = params[:view]
    end
end
