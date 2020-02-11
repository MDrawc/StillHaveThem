module GameManager
  class EditGame
    attr_reader :errors, :message, :game_id, :new_game_id, :platform_name,
                :collection

    def initialize(user:, collection_id:, data:)
      @user = user
      @collection_id = collection_id
      @last_platform = data[:last_platform]
      @last_physical = data[:last_physical] == 'true'
      @igdb_id = data[:igdb_id]
      @game_id = data[:id]
      @platform_id, @platform_name = data[:platform].split(',')
      @physical = data[:physical] == 'true'
      @errors = []
    end

    def call
      unless no_changes
        find_collection
        get_creation_time
        if find_such_game
          add_the_game
        else
          use_similiar
        end
      else
        @errors << 'No changes detected'
      end
    end

    private
      def no_changes
        (@last_platform == @platform_name) && (@last_physical == @physical)
      end

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

      def add_the_game
        begin
          @collection.games << @game
          @new_game_id = @game.id
          save_platform
          fix_creation_time
          compose_message
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        else
          @collection.games.delete(@game_id)
        end
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

      def use_similiar
        @game = Game.find_by(igdb_id: @igdb_id).amoeba_dup
        @game.needs_platform = true
        @game.platform = @platform_id
        @game.platform_name = @platform_name
        @game.physical = @physical

        if @game.save
          @new_game_id = @game.id
          @collection.games << @game
          save_platform
          @collection.games.delete(@game_id)
          fix_creation_time
          compose_message
        else
          @errors += @game.errors.full_messages
        end
      end

      def compose_message
        @message = NotifManager::EditNotif.call(game: @game,
                                                ex_platform: @last_platform,
                                                ex_physical: @last_physical)
      end
  end
end
