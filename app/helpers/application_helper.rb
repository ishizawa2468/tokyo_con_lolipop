module ApplicationHelper
  include ActionView::Helpers::TextHelper

  # ページごとの完全なtitleを返す
  def full_title(page_title = '')
    base_title = "Tokyo Consulting Club"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
end
