class GetLastVisitedPath < ApplicationService
  def initialize(user:, cookie:)
    @user = user
    @cookie = cookie
  end

  def call
    get_collection_ids
    prepare_path
  end

  private
    def get_collection_ids
      @collection_ids = @user.collection_ids
    end

    def prepare_path
      if @collection_ids.include?(@cookie.to_i)
        collection_id = @cookie
      elsif @cookie != 'search'
        collection_id = @collection_ids[0] if !@collection_ids.empty?
      end
      path = collection_id ? "/collections/#{ collection_id }" : '/search'
    end
end
