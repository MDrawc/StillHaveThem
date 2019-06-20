class GamesController < ApplicationController
  before_action :require_user

  def create
    @collection = current_user.collections.find_by_id(params[:collection])

    if @collection.needs_platform
      platform, platform_name = game_params[:platform].split(',')
      @form_type = params[:form_type]

      if @game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical ])

        begin
          @collection.games << @game
        rescue ActiveRecord::RecordNotUnique
          #error!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end

      else
        @game = @collection.games.build(game_params.except(:platform))
        @game.platform, @game.platform_name = platform, platform_name

        if @game.save
        else
          @errors = @game.errors.full_messages
        end
      end
    else
      if @game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)

        begin
          @collection.games << @game
        rescue ActiveRecord::RecordNotUnique
          #error!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end

      else
        @game = @collection.games.build(game_params)

        if @game.save
        else
          @errors = @game.errors.full_messages
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
     :status, :category, :needs_platform, :platform, :physical, platforms: [])
  end

end
