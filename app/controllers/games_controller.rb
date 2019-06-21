class GamesController < ApplicationController
  before_action :require_user

  def create
    @errors = []
    @collection = current_user.collections.find_by_id(params[:collection])
    @form_type = params[:form_type]

    if @collection.needs_platform
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
    else # Does not need platform:
      if @game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)
        begin
          @collection.games << @game
          message(false, false)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in your collection'
          message(false, true)
        end
      else
        @game = @collection.games.build(game_params)

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

private

  def message(needs_platform = true, duplicate = false)
    if needs_platform
      if !duplicate
        @message_type = 'primary'
        @message = "Added \"#{@game.name}\"" +
        " [ #{@game.platform_name} | #{@game.physical ? 'Physical' : 'Digital'} ]" +
        " to \"#{@collection.custom_name || @collection.name}\"."
      else
        @message_type = false
      end
    else
      if !duplicate
        @message_type = 'primary'
        @message = "Added \"#{@game.name}\"" +
        " to \"#{@collection.custom_name || @collection.name}\"."
      else
        @message_type = 'warning'
        @message = "\"#{@game.name}\"" +
        " is already in the \"#{@collection.custom_name || @collection.name}\"." +
        " Nothing added."
      end
    end
  end

  def game_params
    params.require(:game).permit(:name, :igdb_id, :first_release_date, :summary,
     :status, :category, :needs_platform, :platform, :physical, platforms: [])
  end

end
