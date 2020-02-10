class CreateCollectionLink < ApplicationService
  include Rails.application.routes.url_helpers

  def initialize(collection:)
    @collection = collection
  end

  def call
    "<a class='c' data-remote='true' href='#{ collection_path(@collection) }' >#{ @collection.name }</a>"
  end
end
