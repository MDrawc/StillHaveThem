module ApplicationHelper

  def title
    logged_in? ? 'My Video Games' : 'Still Have Them'
  end

  def svg(name)
    file_path = "#{Rails.root}/app/assets/images/#{name}.svg"
    return File.read(file_path).html_safe if File.exists?(file_path)
    '(not found)'
  end

  def edit_open?
    return true if cookies[:edit_open] == 'true'
  end
end
