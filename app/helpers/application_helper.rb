module ApplicationHelper

  def title(page_title = '')
    base_title = 'still have them'
    page_title.empty? ? base_title : base_title + ' > ' +page_title
  end

end
