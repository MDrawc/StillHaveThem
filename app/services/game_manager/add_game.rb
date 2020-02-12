module GameManager
  class AddGame
    attr_reader :errors, :igdb_id, :message

    def initialize(user:, collection:, data:)
      @user = user
      @collection = collection
      @needs_platform = collection.needs_platform
      @agame_id = data[:id]
      @igdb_id = data[:igdb_id]
      @errors = []

      if @needs_platform
        @platform_id, @platform_name = data[:platform].split(',')
        @physical = data[:physical]
      end
    end

    def call
      if find_the_same_game
        add_found_game
      elsif find_similiar_game
        duplicate_and_modify
        add_found_game
      else
        create_from_agame and
          save_new_game
      end
    end

    private
      def find_the_same_game
        if @needs_platform
          @game = Game.find_by(igdb_id: @igdb_id,
                               platform: @platform_id,
                               physical: @physical)
        else
          @game = Game.find_by(igdb_id: @igdb_id, needs_platform: false)
        end
      end

      def add_found_game
        begin
          @collection.games << @game
          save_platform if @needs_platform
          compose_message
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Already in collection'
        end
      end

      def find_similiar_game
        @game = Game.find_by(igdb_id: @igdb_id)
      end

      def duplicate_and_modify
        @game = @game.amoeba_dup
        if @needs_platform
          @game.needs_platform = true
          @game.platform = @platform_id
          @game.platform_name = @platform_name
          @game.physical = @physical
        else
          @game.needs_platform = false
          @game.platform = nil
          @game.platform_name = nil
          @game.physical = nil
        end
      end

      def save_platform
        AddPlatform.call(user: @user,
                         platform_id: @platform_id,
                         platform_name: @platform_name)
      end

      def create_from_agame
        if agame = Agame.find_by_id(@agame_id)
          build_from_agame(agame)
          add_developers(agame.developers)
          return true
        else
          @errors << 'Please repeat the search'
          return false
        end
      end

      def build_from_agame(agame)
        @game = @collection.games.build(convert_agame(agame))
        if @needs_platform
          @game.needs_platform = true
          @game.platform = @platform_id
          @game.platform_name = @platform_name
          @game.physical = @physical
        end
      end

      def save_new_game
        begin
        if @game.save
          save_platform if @needs_platform
          compose_message
        else
          @errors += @game.errors.messages.values
        end
        rescue ActiveRecord::RecordNotUnique
          @errors << 'Please try again'
        end
      end

      def convert_agame(agame)
        agame.data_for_game_creation
      end

      def compose_message
        @message = NotifComposer::ComposeAddNotif.call(game: @game,
                                                   collection: @collection)
      end

      def add_developers(devs)
        if devs
          devs.uniq!
          found = Developer.where(name: devs)
          not_found = devs - found.map(&:name)
          added = Developer.create(not_found.map { |d| { name: d } })
          @game.developers << (found + added)
        end
      end
  end
end
