class ExportsController < ApplicationController
  before_action :require_user

  def export_collections
    @collections = current_user.collections
    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=sht_export_collections.xlsx"
      }
    end
  end

  def export_platforms
    @user_id = current_user.id
    respond_to do |format|
      format.xlsx {
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=sht_export_platforms.xlsx"
      }
    end
  end
end
