module ApplicationHelper

  def title
    cookies[:title] || 'still have them'
  end

  def svg(name)
    file_path = "#{Rails.root}/app/assets/images/#{name}.svg"
    return File.read(file_path).html_safe if File.exists?(file_path)
    '(not found)'
  end

  def edit_open?
    cookies[:edit_open] == 'true'
  end

  def ucs_closed?
    cookies[:ucs_closed] == 'true'
  end

  def tb_open?
    cookies[:tb_open] || ''
  end

  def addl_hidden?
    cookies[:addl_hidden] == 'true'
  end

  def current_theme
    cookies[:theme] || 'theme_default'
  end

end
