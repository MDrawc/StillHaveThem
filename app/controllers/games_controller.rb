class GamesController < ApplicationController
  before_action :require_user
  before_action :find_game_and_collection, only: [:edit_form, :cm_form]

  def create
    @errors = []
    @collection = current_user.collections.find_by_id(params[:collection])
    @game_igdb_id = game_params[:igdb_id]

    if @collection
      @form = @collection.form
    else
      @errors << 'Select collection'
      @form = params[:form]
    end

    if @collection && @collection.needs_platform
      platform, platform_name = game_params[:platform].split(',')

      if @game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical ])

        begin
          @collection.games << @game
          message(@game, true, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end

      else
        @game = @collection.games.build(game_params.except(:platform))
        @game.platform, @game.platform_name = platform, platform_name

        if @game.save
          message(@game, true, false)
        else
          @errors += @game.errors.full_messages
        end
      end
    elsif @collection # Does not need platform:
      if @game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)
        begin
          @collection.games << @game
          message(@game, false, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
          message(@game, false, true) unless @form == 'custom'
        end
      else
        @game = @collection.games.build(game_params.except(:platform, :physical))

        if @game.save
          message(@game, false, false)
        else
          @errors += @game.errors.full_messages
        end
      end
    end

    respond_to :js
  end

  def edit_form
    respond_to :js
  end

  def cm_form
    respond_to :js
  end

  def edit
    @errors = []
    @collection = current_user.collections.find(params[:current].to_i)
    @game_id = params[:game_id].to_i
    last_platform, last_physical = params[:last_platform], eval(params[:last_physical])

    platform, platform_name = game_params[:platform].split(',')
    game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical])

    if game && (game.id == @game_id)
      @errors << 'No changes detected'
    elsif game
      begin
        @collection.games.delete(@game_id)
        @collection.games << game
        edit_message(last_platform, last_physical, game)
      rescue ActiveRecord::RecordNotUnique
        @errors << 'Already in collection'
      end
    else
      game = Game.find_by(igdb_id: game_params[:igdb_id]).dup
      game.platform, game.platform_name = platform, platform_name
      game.physical = game_params[:physical]
      game.needs_platform = true

      if game.save
        @collection.games.delete(@game_id)
        @collection.games << game
        edit_message(last_platform, last_physical, game)
      else
        @errors += game.errors.full_messages
      end
    end

    respond_to :js
  end

  def copy_move
    @errors = []
    @game_id = params[:game_id]
    @copy = eval(params[:copy])
    p_verb = @copy ? 'copied' : 'moved'


    if params[:collection].empty?
      @errors << 'Select collection'
      @current = current_user.collections.find(params[:current].to_i)
    else
      coll_ids = [params[:current].to_i, params[:collection].split(',').first.to_i]
      cord = coll_ids == coll_ids.sort ? :asc : :desc

      if coll_ids.uniq.size == 1
        @collection = @current = current_user.collections.find(coll_ids.first)
      else
        @current, @collection = current_user.collections.where(id: coll_ids).order(id: cord)
      end

      if needs_plat = @collection.needs_platform
        platform, platform_name = game_params[:platform].split(',')
        game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical])
      else
        game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)
      end

      if game
        begin
          @collection.games << game
          message(game, needs_plat, false, p_verb)
          unless @copy
            @current.games.delete(@game_id)
          end
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end
      else
        game = Game.find_by(igdb_id: game_params[:igdb_id]).dup
        if needs_plat
          game.platform, game.platform_name = platform, platform_name
          game.physical = game_params[:physical]
          game.needs_platform = true
        else
          game.platform, game.platform_name = nil, nil
          game.physical = nil
          game.needs_platform = false
        end

        if game.save
          message(game, needs_plat, false, p_verb)
          @collection.games << game

          unless @copy
            @current.games.delete(@game_id)
          end

        else
          @errors += game.errors.full_messages
        end
      end
    end
    respond_to :js
  end

  private
    def game_params
      params.require(:game).permit(:name, :igdb_id, :first_release_date, :summary,
       :status, :category, :needs_platform, :platform, :physical, :cover, :cover_width, :cover_height, platforms: [], platforms_names: [], developers: [], screenshots: [])
    end

    def find_game_and_collection
      @collection = current_user.collections.find_by_id(params[:collection_id])
      @game = @collection.games.find_by_id(params[:game_id])
    end

    def message(game, needs_platform = true, duplicate = false, p_verb = 'added')
      collection_link = "<a class='c' data-remote='true' href='#{collection_path(@collection)}' >#{ @collection.called }</a>"

      if needs_platform
        if !duplicate
          @message = "<span class='g'>#{ p_verb.capitalize }</span> #{ game.name }" +
          " <span class='d'>(#{ game.platform_name}, #{ game.physical ? 'Physical' : 'Digital'})</span>" +
          " to " + collection_link
        else
          @message = nil
        end
      else
        if !duplicate
          @message = "<span class='g'>#{ p_verb.capitalize }</span> #{ game.name }" +
          " to " + collection_link
        else
          @message = "#{ game.name }" +
          " <span class='b'>already belongs</span> to " + collection_link
        end
      end
    end

    def edit_message(last_platform, last_physical, game)
      @message = "<span class='g'>Edited</span> #{ game.name }: " +
      "<span class='d'>(#{ last_platform}, #{ last_physical ? 'Physical' : 'Digital'})</span> -> " +
      "<span class='d'>(#{ game.platform_name}, #{ game.physical ? 'Physical' : 'Digital'})</span>"
    end
end
