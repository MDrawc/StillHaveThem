module ApplicationHelper

  def title
    cookies[:title] || 'Still Have Them'
  end

  def favicon(theme)
    icon = theme == 'theme_default' ? 'favicon.ico' : 'favicon_dark.ico'
    return favicon_link_tag asset_path(icon), id: 'favicon-control'
  end

  def svg(name)
    file_path = "#{Rails.root}/app/assets/images/#{name}.svg"
    return File.read(file_path).html_safe if File.exists?(file_path)
    '(not found)'
  end

  def edit_open?
    cookies[:edit_open] == 'true'
  end

  def ucs_closed?(shared)
    cookie = shared ? :sh_ucs_closed : :ucs_closed
    cookies[cookie] == 'true'
  end

  def tb_open?(shared)
    cookie = shared ? :sh_tb_open : :tb_open
    cookies[cookie] || ''
  end

  def addl_hidden?
    cookies[:addl_hidden] == 'true'
  end

  def current_theme
    cookies[:theme] || 'theme_default'
  end

  def current_sh_theme
    cookies[:sh_theme] || 'theme_default'
  end

end
