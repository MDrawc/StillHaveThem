class GamesController < ApplicationController
  before_action :require_user

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
          @errors << 'Already in your collection'
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
          @errors << 'Already in your collection'
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

    respond_to do |format|
      format.js
    end
  end

  def copy
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

      puts "coll ids: #{coll_ids}"
      puts "cord: #{cord}"
      puts "current: #{@current}"
      puts "collection: #{@collection}"

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
            puts 'removing found' + ' *' * 100
            @current.games.delete(@game_id)
          end
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in your collection'
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
            puts 'removing new' + ' *' * 100
            @current.games.delete(@game_id)
          end

        else
          @errors += game.errors.full_messages
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end

  private

    def game_params
      params.require(:game).permit(:name, :igdb_id, :first_release_date, :summary,
       :status, :category, :needs_platform, :platform, :physical, :cover, :cover_width, :cover_height, platforms: [], platforms_names: [], developers: [], screenshots: [])
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
end
