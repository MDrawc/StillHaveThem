class FindOwnedGames < ApplicationService
  def initialize(user:, results:)
    @user = user
    @results = results
  end

  def call
    get_games_ids
    return_owned_games_ids
  end

  private

  def get_games_ids
    @game_ids = @results.pluck(:igdb_id)
  end

  def return_owned_games_ids
    result = []
    @user.collections.includes(:games).each do |c|
      result += c.games.where(igdb_id: @game_ids).pluck(:igdb_id)
    end
    result.uniq
  end
end
