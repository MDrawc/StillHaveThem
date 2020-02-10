class AddCopyNotif < ApplicationService
  def initialize(game:, collection:, verb: 'added')
    @game = game
    @collection = collection
    @verb = verb
  end

  def call
    collection_link = CreateCollectionLink.call(collection: @collection)
    if @collection.needs_platform
      message = "<span class='g'>#{ @verb.capitalize }</span> #{ @game.name }" +
      " <span class='d'>(#{ @game.platform_name}, #{ @game.physical ? 'Physical' : 'Digital'})</span>" +
      " to " + collection_link
    else
      message = "<span class='g'>#{ @verb.capitalize }</span> #{ @game.name }" +
      " to " + collection_link
    end
  end
end

