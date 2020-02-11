  def edit
    @view = params[:view]
    edit_game = EditGame.new(user: current_user,
                        collection_id: params[:collection],
                        data: game_params)


    #temporary
    @errors = []

    #strange

    collection_id = params[:collection].to_i
    @collection = current_user.collections.find(collection_id)

    @game_id = params[:game_id].to_i

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
