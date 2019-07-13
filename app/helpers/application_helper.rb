module ApplicationHelper

  def title(page_title = '')
    base_title = 'still have them'
    page_title.empty? ? base_title : base_title + ' > ' +page_title
  end

  def svg(name)
    file_path = "#{Rails.root}/app/assets/images/#{name}.svg"
    return File.read(file_path).html_safe if File.exists?(file_path)
    '(not found)'
  end

end
