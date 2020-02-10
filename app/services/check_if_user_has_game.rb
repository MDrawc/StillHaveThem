class CheckIfUserHasGame < ApplicationService
  def initialize(user:, igdb_id:)
    @user = user
    @igdb_id = igdb_id
  end

  def call
    results = []
    @user.collections.includes(:games).each do |collection|
      results << collection.games.any? { |game| game.igdb_id == @igdb_id }
    end
    return results.any?
  end
end
