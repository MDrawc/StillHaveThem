module SharesHelper
  def guest
    @share ||= Share.find_by(id: session[:share_id]) if session[:share_id]
  end

  def guest_logged?
    !!guest
  end

  def shared_collections
     collections = Collection.where('id IN (?)', guest.shared)
  end

  def log_guest(share)
    session[:share_id] = share.id
  end

  def kill_guest
    session.delete(:share_id)
    @share = nil
  end
end
