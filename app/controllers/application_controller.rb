class ApplicationController < ActionController::Base
  include SessionsHelper
  include SharesHelper

  def reload
    respond_to do |format|
      format.js {render js: 'location.reload();' }
    end
  end

  def js_partial(partial, locals)
    respond_to do |format|
      format.js { render partial: partial, locals: locals }
    end
  end
end
