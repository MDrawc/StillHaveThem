class AddGame < ApplicationService
  attr_reader :errors, :igdb_id, :message

  def initialize(user:, collection:, data:, x_id:)
    @user = user
    @collection = collection
    @needs_platform = collection.needs_platform
    @data = data
    @igdb_id = data[:igdb_id]
    @x_id = x_id
    @errors = []
  end

  def call
    if find_the_same_game
      add_the_game
    else
      create_the_game_from_agame
    end
  end

  private
    def find_the_same_game
      if @needs_platform
        platform_id = @data[:platform].split(',').first
        physical = @data[:physical]
        @game = Game.find_by(igdb_id: @igdb_id,
                             platform: platform_id,
                             physical: physical)
      else
        @game = Game.find_by(igdb_id: @igdb_id, needs_platform: false)
      end
    end

    def add_the_game
      begin
        @collection.games << @game
        save_platform if @needs_platform
        @message = AddCopyNotif.call(game: @game, collection: @collection)
      rescue ActiveRecord::RecordNotUnique
        @errors << 'Already in collection'
      end
    end

    def save_platform
      platform_id, platform_name = @data[:platform].split(',')
      AddPlatform.call(user: @user,
                       platform_id: platform_id,
                       platform_name: platform_name)
    end

    def create_the_game_from_agame
    end
end



    agame_id = game_params[:id]






    if @collection.needs_platform



      platform, platform_name = game_params[:platform].split(',')
      physical = game_params[:physical]

      if @game = Game.find_by(igdb_id: game_params[:igdb_id], platform: platform, physical: physical)
        begin
          @collection.games << @game
          save_platform(platform, platform_name)

          @message = AddCopyNotif.call(game: @game, collection: @collection)

        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end
      else
        create_from_agame(agame_id, true, platform, platform_name, physical)
      end


    else


      if @game = Game.find_by(igdb_id: game_params[:igdb_id], needs_platform: false)

        begin
          @collection.games << @game
          @message = AddCopyNotif.call(game: @game, collection: @collection)
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end

      else
        create_from_agame(agame_id)
      end


    end
