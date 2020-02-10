class ChangeCollectionsOrder < ApplicationService
  include Rails.application.routes.url_helpers

  def initialize(user:, new_order:)
    @user = user
    @new_order = new_order
  end

  def call
    @user.collections.each do |c|
      coll_id = c.id.to_s
      c.update(cord: @new_order[coll_id]) if @new_order.keys.include?(coll_id)
    end
  end
end
