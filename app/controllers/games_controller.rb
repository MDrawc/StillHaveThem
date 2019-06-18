class GamesController < ApplicationController
  before_action :require_user

  def create
    @collection = current_user.collections.find_by_id(params[:collection])

    if Game.exists?(igdb_id: game_params[:igdb_id])
      @game = Game.find_by(igdb_id: game_params[:igdb_id])

      begin
        @collection.games << @game
      rescue ActiveRecord::RecordNotUnique
        flash.now[:danger] = "Cant Add game :("
      end


    else
      @game = @collection.games.build(game_params)
      if @game.save
        flash.now[:success] = "Game added to your collection"
      else
        flash.now[:danger] = "Cant Add game :("
      end
    end
  end

private

  def game_params
    params.require(:game).permit(:name, :igdb_id, :first_release_date, :summary, :status, :category)
  end

end
