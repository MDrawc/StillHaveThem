module SharesHelper
  def guest
    @share ||= Share.find_by(id: session[:share_id]) if session[:share_id]
  end

  def guest_logged?
    !!guest
  end

  def shared_collections
     Collection.where(id: guest.shared)
  end

  def log_guest(share)
    session[:share_id] = share.id
  end

  def kill_guest
    session.delete(:share_id)
    @share = nil
  end

  def require_guest
    unless guest_logged?
      respond_to do |format|
        format.js {render js: 'location.reload();' }
      end
    end
  end
end
