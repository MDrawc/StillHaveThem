class CopyGame
  attr_reader :errors, :message, :platform_name, :inside_current, :current, :collection,

  def initialize(user:, current_id:, collection_info:, copy:, data:)
    @user = user
    @current_id = current_id
    @collection_info = collection_info
    @copy = copy
    @game_id = data[:id]
    @igdb_id = data[:igdb_id]
    @platform_id, @platform_name = data[:platform].split(',')
    @physical = data[:physical]
    @errors = []
  end

  def call
    if collection_not_selected
      @errors << 'Select collection'
    else
      find_current_and_target_collection
      if find_such_game
        add_or_move_the_game
      else
        find_similiar
        modify_the_game
        save_the_game
      end
    end
  end

  private







    def find_collection
      @collection = @user.collections.find(@collection_id)
    end

    def find_such_game
      @game = Game.find_by(igdb_id: @igdb_id,
                           platform: @platform_id,
                           physical: @physical)
    end

    def get_creation_time
      @created_at = CollectionGame.find_by(collection_id: @collection_id,
                                           game_id: @game_id).created_at
    end

    def fix_creation_time
      new_rec = CollectionGame.find_by(collection_id: @collection_id, game_id: @new_game_id)
      new_rec.created_at = @created_at
      new_rec.save
    end

    def save_platform
      AddPlatform.call(user: @user,
                       platform_id: @platform_id,
                       platform_name: @platform_name)
    end
end
