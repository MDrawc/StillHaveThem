class PlatformsController < ApplicationController
  before_action :require_user
  before_action :correct_user

  def destroy
    current_user.platforms.delete(@platform)
    respond_to :js
  end

  private
    def correct_user
      @platform = current_user.platforms.find_by(id: params[:id])
      reload if @platform.nil?
    end
end
