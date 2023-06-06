module PaginationHelper
  def pagy_pagination(pagy)
    link = pagy_link_proc(pagy)
    pagination_links = "<div class='pagination'>"

    if pagy.prev
      pagination_links += link.call(pagy.prev, pagy_t('pagy.nav.prev'), 'aria-label="previous"')
    else
      pagination_links += "<span class='page prev disabled'>#{pagy_t('pagy.nav.prev')}</span>"
    end

    if pagy.next
      pagination_links += link.call(pagy.next, pagy_t('pagy.nav.next'), 'aria-label="next"')
    else
      pagination_links += "<span class='page next disabled'>#{pagy_t('pagy.nav.next')}</span>"
    end

    pagination_links += "</div>"

    pagination_links.html_safe
  end
end
