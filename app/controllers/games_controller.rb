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
          message(true, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in your collection'
        end

      else
        @game = @collection.games.build(game_params.except(:platform))
        @game.platform, @game.platform_name = platform, platform_name

        if @game.save
          message(true, false)
        else
          @errors += @game.errors.full_messages
        end
      end
    elsif @collection # Does not need platform:
      if @game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)
        begin
          @collection.games << @game
          message(false, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in your collection'
          message(false, true) unless @form == 'custom'
        end
      else
        @game = @collection.games.build(game_params.except(:platform, :physical))

        if @game.save
          message(false, false)
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
    @collection = current_user.collections.find_by_id(params[:collection])
    @game_id = params[:game_id]

    if @collection && @collection.needs_platform

      platform, platform_name = game_params[:platform].split(',')

      if @game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical ])
        begin
          @collection.games << @game
          message(true, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in your collection'
        end
      else
        @game = @collection.games.build(game_params.except(:platform))
        @game.platform, @game.platform_name = platform, platform_name

        if @game.save
          message(true, false)
        else
          @errors += @game.errors.full_messages
        end
      end

    elsif @collection

      if @game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)
        begin
          @collection.games << @game
          message(false, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in your collection'
        end
      else
        @game = @collection.games.build(game_params.except(:platform, :physical))
        if @game.save
          message(false, false)
        else
          @errors += @game.errors.full_messages
        end
      end

    else
      @errors << 'Select collection'
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

    def message(needs_platform = true, duplicate = false)
      collection_link = "<a class='c' data-remote='true' href='#{collection_path(@collection)}' >#{ @collection.called }</a>"

      if needs_platform
        if !duplicate
          @message = "<span class='g'>Added</span> #{@game.name}" +
          " <span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span>" +
          " to " + collection_link
        else
          @message = nil
        end
      else
        if !duplicate
          @message = "<span class='g'>Added</span> #{@game.name}" +
          " to " + collection_link
        else
          @message = "#{@game.name}" +
          " <span class='b'>already belongs</span> to " + collection_link
        end
      end
    end
end
