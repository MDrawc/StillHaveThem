class ApplicationController < ActionController::Base
  include SessionsHelper
  include CollectionsHelper
  include SharesHelper
end
