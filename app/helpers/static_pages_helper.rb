module StaticPagesHelper
  def present_bar_record(record)
    type = record.query_type

    case type
    when 'game' then endpoint = 'game'
    when 'char' then endpoint = 'character'
    when 'dev' then  endpoint = 'developer'
    end

    ago = time_ago_in_words(record.created_at) + ' ago'

    results = pluralize(record.results, 'result')

    results += ' (filters)' if record.custom_filters

    results = results.sub('50', '50+')

    extr = ago + content_tag(:span, results)

    unless custom = record.custom_filters
      content_tag(:div, class: 'record', 'e': type, 'i': record.inquiry, 'cf': custom) do
        concat endpoint
        concat content_tag :span, record.inquiry, class: 'input uk-text-truncate'
        concat content_tag :div, extr.html_safe, class: 'extr'
      end
    else
      content_tag(:div, class: 'record', 'e': type, 'i': record.inquiry, 'cf': custom, 'f': record.filters) do
        concat endpoint
        concat content_tag :span, record.inquiry, class: 'input uk-text-truncate'
        concat content_tag :div, extr.html_safe, class: 'extr'
      end
    end
  end
end



