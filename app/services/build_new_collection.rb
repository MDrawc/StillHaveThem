class BuildNewCollection < ApplicationService
  def initialize(user:, data:)
    @user = user
    @data = data
  end

  def call
    get_last_collection_order_number
    build_collection
  end

  private
    def get_last_collection_order_number
      if (last_coll = @user.collections.last)
        @order_number = last_coll.cord + 1
      else
        @order_number = 1
      end
    end

    def build_collection
      collection = @user.collections.build(@data)
      collection.cord = @order_number
      collection
    end
end
