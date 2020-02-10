class RemoveNotif < ApplicationService
  def initialize(game:, collection:)
    @game = game
    @collection = collection
  end

  def call
    compose_message
  end

  private
    def compose_message
      message = "<span class='b'>Removed</span> #{@game.name} "
      if @collection.needs_platform
        message += "<span class='d'>(#{@game.platform_name}, #{@game.physical ? 'Physical' : 'Digital'})</span> "
      end
      message += "from " + CreateCollectionLink.call(collection: @collection)
    end
end
