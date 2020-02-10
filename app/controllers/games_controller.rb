class GamesController < ApplicationController
  before_action :require_user, except: [:cover_show, :list_show, :panel_show]
  before_action :find_game_and_collection, only: [:edit_form, :copy_form]
  before_action :find_collection, only: [:create]
  before_action :find_agame, only: [:list_show, :cover_show, :panel_show]
  respond_to :js

  def new
    @game = Game.new()
    @x_id = params[:x_id]
    @owned = params[:owned] == 'true'
    @data = GetDataForGameAdding.call(x_id: @x_id)
  end

  def create
    @x_id = params['x_id']
    add_game = AddGame.call(user: current_user,
                            collection: @collection,
                            data: game_params,
                            x_id: @x_id)
    @errors = add_game.errors
    @message = add_game.message
    @igdb_id = add_game.igdb_id
  end

  def edit_form
    @view = params[:view]
  end

  def copy_form
    @view = params[:view]
  end

  def list_show
    @hg_id = params[:hg_id]
  end

  def cover_show
  end

  def panel_show
    @g_id = params[:g_id]
  end

  def edit
    collection_id = params[:current].to_i
    @collection = current_user.collections.find(collection_id)
    @errors = []
    @game_id = params[:game_id].to_i
    @view = params[:view]

    created_at = CollectionGame.find_by(collection_id: collection_id, game_id: @game_id).created_at

    last_platform, last_physical = params[:last_platform], eval(params[:last_physical])
    platform, platform_name = game_params[:platform].split(',')

    @new_platform = platform_name

    game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical])

    if game && (game.id == @game_id)
      @errors << 'No changes detected'
    elsif game
      begin
        @collection.games << game
        save_platform(platform, platform_name)
        @new_game_id = game.id
        @igdb_id = game.igdb_id

        new_rec = CollectionGame.find_by(collection_id: collection_id, game_id: game.id)
        new_rec.created_at = created_at
        new_rec.save


        @message = EditNotif.call(game: game,
                                  ex_platform: last_platform,
                                  ex_physical: last_physical)



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
        @igdb_id = game.igdb_id

        @collection.games << game
        save_platform(platform, platform_name)

        @collection.games.delete(@game_id)

        new_rec = CollectionGame.find_by(collection_id: collection_id, game_id: game.id)
        new_rec.created_at = created_at
        new_rec.save




        @message = EditNotif.call(game: game,
                          ex_platform: last_platform,
                          ex_physical: last_physical)
      else
        @errors += game.errors.full_messages
      end
    end
  end

  def copy_move
    @errors = []
    game_id = params[:game_id]
    @view = params[:view]
    @copy = eval(params[:copy])
    verb = @copy ? 'copied' : 'moved'
    @wi_same_coll = false;

    if params[:collection].empty?
      @errors << 'Select collection'
      @current = current_user.collections.find(params[:current].to_i)
    else
      coll_ids = [params[:current].to_i, params[:collection].split(',').first.to_i]
      cord = coll_ids == coll_ids.sort ? :asc : :desc

      if coll_ids.uniq.size == 1
        @collection = @current = current_user.collections.find(coll_ids[0])
        @wi_same_coll = true
      else
        @current, @collection = current_user.collections.where(id: coll_ids).unscope(:order).order(id: cord)
      end

      if needs_plat = @collection.needs_platform
        platform, platform_name = game_params[:platform].split(',')
        @new_platform = platform_name
        game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical])
      else
        game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)
      end

      if game
        begin
          @collection.games << game
          save_platform(platform, platform_name) if needs_plat

          @message = AddCopyNotif.call(game: game,
                                       collection: @collection,
                                       verb: verb)

          unless @copy
            @current.games.delete(game_id)
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

          @message = AddCopyNotif.call(game: game,
                                       collection: @collection,
                                       verb: verb)

          @collection.games << game
          save_platform(platform, platform_name) if needs_plat

          unless @copy
            @current.games.delete(game_id)
          end

        else
          @errors += game.errors.full_messages
        end
      end

    end
  end





















  private
    def game_params
      params.require(:game).permit(:id, :igdb_id, :collection, :needs_platform, :platform, :physical)
    end

    def find_agame
      @game = Agame.find_by(igdb_id: params[:igdb_id])
    end

    def find_game_and_collection
      @collection = current_user.collections.find_by_id(params[:collection_id])
      if @collection.nil?
        reload
      else
        @game = @collection.games.find_by_id(params[:game_id])
      end
    end

    def find_collection
      coll_id = game_params[:collection].split(',').first.to_i
      @collection = current_user.collections.find_by_id(coll_id)
      reload if @collection.nil?
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


          @message = AddCopyNotif.call(game: @game, collection: @collection)

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

    def add_developers(devs)
      if devs
        devs.uniq!
        found = Developer.where(name: devs)
        not_found = devs - found.map(&:name)
        added = Developer.create(not_found.map { |d| { name: d } })
        @game.developers << (found + added)
      end
    end

    def save_platform(id, name)



      unless current_user.platforms.find_by(igdb_id: id)
        unless new_platform = Platform.find_by(igdb_id: id)
          new_platform = Platform.create(igdb_id: id, name: name)
        end
        current_user.platforms << new_platform
      end



    end
end
