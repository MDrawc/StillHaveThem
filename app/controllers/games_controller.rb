class GamesController < ApplicationController
  before_action :require_user
  before_action :find_game_and_collection, only: [:edit_form, :cm_form]
  SR_HEX = 2

  def new
    @game = Game.new()
    x_id = params[:x_id]
    igdb_id = x_id.include?('-') ?  x_id.slice(0..-(2*SR_HEX+1)) : x_id

    @data = Agame.find_by(igdb_id: igdb_id).attributes.slice('id',
     'igdb_id',
      'name',
       'platforms',
        'platforms_names').symbolize_keys

    @x_id = x_id
    @owned = eval(params[:owned])
    respond_to :js
  end

  def create
    agame_id = game_params[:id]
    coll_id = game_params[:collection] .split(',').first.to_i
    @x_id = params['x_id']

    @errors = []
    @collection = current_user.collections.find_by_id(coll_id)
    @game_igdb_id = game_params[:igdb_id]

    if @collection && @collection.needs_platform
      platform, platform_name = game_params[:platform].split(',')
      physical = game_params[:physical]

      if @game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: physical)
        begin
          @collection.games << @game
          save_platform(platform, platform_name)
          message(@game, true)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end
      else
        create_from_agame(agame_id, true, platform, platform_name, physical)
      end

    elsif @collection
      if @game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)
        begin
          @collection.games << @game
          message(@game, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end
      else
        create_from_agame(agame_id)
      end
    else
      @errors << 'Select collection'
    end

    respond_to :js
  end

  def edit_form
    @view = params[:view]
    respond_to :js
  end

  def cm_form
    @view = params[:view]
    respond_to :js
  end

  def table_show
    @game = Game.find_by_id(params[:game_id])
    respond_to :js
  end

  def cover_show
    @game = Game.find_by_id(params[:game_id])
    @user_id  = current_user.id
    respond_to :js
  end

  def edit
    @errors = []
    collection_id = params[:current].to_i
    @collection = current_user.collections.find(collection_id)
    @game_id = params[:game_id].to_i
    @view = params[:view]

    created_at = CollectionGame.find_by(collection_id: collection_id, game_id: @game_id).created_at

    last_platform, last_physical = params[:last_platform], eval(params[:last_physical])
    platform, platform_name = game_params[:platform].split(',')
    game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical])

    if game && (game.id == @game_id)
      @errors << 'No changes detected'
    elsif game
      begin
        @collection.games << game
        @new_game_id = game.id

        new_rec = CollectionGame.find_by(collection_id: collection_id, game_id: game.id)
        new_rec.created_at = created_at
        new_rec.save

        edit_message(last_platform, last_physical, game)
      rescue ActiveRecord::RecordNotUnique
        @errors << 'Already in collection'
      else
        @collection.games.delete(@game_id)
      end
    else
      game = Game.find_by(igdb_id: game_params[:igdb_id]).amoeba_dup
      game.platform, game.platform_name = platform, platform_name
      game.physical = game_params[:physical]
      game.needs_platform = true

      if game.save
        @new_game_id = game.id

        @collection.games << game
        @collection.games.delete(@game_id)

        new_rec = CollectionGame.find_by(collection_id: collection_id, game_id: game.id)
        new_rec.created_at = created_at
        new_rec.save

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
    @view = params[:view]
    @copy = eval(params[:copy])
    p_verb = @copy ? 'copied' : 'moved'
    @wi_same_coll = false;

    if params[:collection].empty?
      @errors << 'Select collection'
      @current = current_user.collections.find(params[:current].to_i)
    else
      coll_ids = [params[:current].to_i, params[:collection].split(',').first.to_i]
      cord = coll_ids == coll_ids.sort ? :asc : :desc

      if coll_ids.uniq.size == 1
        @collection = @current = current_user.collections.find(coll_ids.first)
        @wi_same_coll = true
      else
        @current, @collection = current_user.collections.where(id: coll_ids).unscope(:order).order(id: cord)
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
          message(game, needs_plat, p_verb)
          unless @copy
            @current.games.delete(@game_id)
          end
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end
      else
        game = Game.find_by(igdb_id: game_params[:igdb_id]).amoeba_dup

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
          message(game, needs_plat, p_verb)
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
      params.require(:game).permit(:id, :igdb_id, :collection, :needs_platform, :platform, :physical)
    end

    def find_game_and_collection
      @collection = current_user.collections.find_by_id(params[:collection_id])
      @game = @collection.games.find_by_id(params[:game_id])
    end

    def create_from_agame(id, needs_platform = false, platform = nil, platform_name = nil, physical = nil)
      if agame = Agame.find_by_id(id)
        @game = @collection.games.build(convert_agame(agame))
        if needs_platform
          @game.needs_platform = true
          @game.platform, @game.platform_name = platform, platform_name
          @game.physical = physical
        end
        add_developers(agame.developers)
        begin
        if @game.save
          save_platform(platform, platform_name) if needs_platform
          message(@game, needs_platform)
        else
          @errors += @game.errors.messages.values
        end
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Please try again in a moment'
        end
      else
        @errors << 'Please repeat the search and try again'
      end
    end

    def convert_agame(agame)
      game_data = agame.as_json.symbolize_keys
      return game_data.except(:id, :created_at, :updated_at, :themes, :developers, :platforms_categories)
    end

    def message(game, needs_platform = true, p_verb = 'added')
      collection_link = "<a class='c' data-remote='true' href='#{collection_path(@collection)}' >#{ @collection.name }</a>"
      if needs_platform
        @message = "<span class='g'>#{ p_verb.capitalize }</span> #{ game.name }" +
        " <span class='d'>(#{ game.platform_name}, #{ game.physical ? 'Physical' : 'Digital'})</span>" +
        " to " + collection_link
      else
        @message = "<span class='g'>#{ p_verb.capitalize }</span> #{ game.name }" +
        " to " + collection_link
      end
    end

    def edit_message(last_platform, last_physical, game)
      @message = "<span class='g'>Edited</span> #{ game.name }: " +
      "<span class='d'>(#{ last_platform}, #{ last_physical ? 'Physical' : 'Digital'})</span> -> " +
      "<span class='d'>(#{ game.platform_name}, #{ game.physical ? 'Physical' : 'Digital'})</span>"
    end

    def add_developers(devs)
      if devs
        found = Developer.where(name: devs)
        not_found = devs - found.map(&:name)
        added = Developer.create(not_found.map { |d| { name: d } })
        @game.developers << (found + added)
      end
    end

    def save_platform(id, name)
      unless current_user.platforms.find_by(igdb_id: id)
        unless new_platform = Platform.find_by({ igdb_id: id, name: name })
          new_platform = Platform.create({ igdb_id: id, name: name })
        end
        current_user.platforms << new_platform
      end
    end
end
