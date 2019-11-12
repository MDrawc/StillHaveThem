class PlatformsController < ApplicationController
  before_action :require_user
  before_action :correct_user

  def destroy


    respond_to :js
  end

  private
    def correct_user
      @share = current_user.shares.find_by(id: params[:id])
      reload if @share.nil?
    end
end
