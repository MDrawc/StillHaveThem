class GamesController < ApplicationController
  before_action :require_user

  def create




    platform, platform_name = game_params[:platform].split(',')

    @form_type = params[:form_type]
    @collection = current_user.collections.find_by_id(params[:collection])

    if Game.exists?(igdb_id: game_params[:igdb_id], platform: platform, physical: game_params[:physical ])
      @game = Game.find_by(igdb_id: game_params[:igdb_id])

      begin
        @collection.games << @game
      rescue ActiveRecord::RecordNotUnique
        flash.now[:danger] = "Cant Add game :("
        @errors = @game.errors.full_messages
      end

    else
      @game = @collection.games.build(game_params.except(:platform))
      if @collection.needs_platform
        @game.platform = platform
        @game.platform_name = platform_name
      end

      if @game.save
        flash.now[:success] = "Game added to your collection"
      else
        flash.now[:danger] = "Cant Add game :("
        @errors = @game.errors.full_messages
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
