module GameManager
  class CopyGame
    attr_reader :errors, :message, :platform_name, :inside_current, :current, :collection

    def initialize(user:, current_id:, collection_info:, copy:, data:)
      @user = user
      @current_id = current_id.to_i
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
      def collection_not_selected
        @collection_info.empty?
      end

      def find_current_and_target_collection
        collection_id = @collection_info.split(',')[0].to_i
        if @current_id == collection_id
          @collection = @current = @user.collections.find(@current_id)
          @inside_current = true
        else
          @current, @collection = @user.collections.where(id: [@current_id, collection_id])
          if @current.id != @current_id
            @current, @collection = @collection, @current
          end
          @inside_current = false
        end
      end

      def find_such_game
        if @needs_platform = @collection.needs_platform
          @game = Game.find_by(igdb_id: @igdb_id, platform: @platform_id, physical: @physical)
        else
          @game = Game.find_by(igdb_id: @igdb_id, needs_platform: false)
        end
      end

      def add_or_move_the_game
        begin
          @collection.games << @game
          save_platform if @needs_platform
          compose_message
          @current.games.delete(@game_id) unless @copy
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end
      end

      def find_similiar
        @game = Game.find_by(igdb_id: @igdb_id).amoeba_dup
      end

      def modify_the_game
        if @needs_platform
          @game.platform, @game.platform_name = @platform_id, @platform_name
          @game.physical = @physical
          @game.needs_platform = true
        else
          @game.platform, @game.platform_name = nil, nil
          @game.physical = nil
          @game.needs_platform = false
        end
      end

      def save_the_game
        if @game.save
          @collection.games << @game
          save_platform if @needs_platform
          compose_message
          @current.games.delete(@game_id) unless @copy
        else
          @errors += @game.errors.full_messages
        end
      end

      def save_platform
        AddPlatform.call(user: @user,
                         platform_id: @platform_id,
                         platform_name: @platform_name)
      end

      def compose_message
        verb = @copy ? 'copied' : 'moved'
        @message = NotifComposer::ComposeAddNotif.call(game: @game,
                                                   collection: @collection,
                                                   verb: verb)
      end
  end
end
