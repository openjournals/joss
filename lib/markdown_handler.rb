class MarkdownHandler
  class << self
    def call(template)
      compiled_source = erb.call(template)
      "MarkdownHandler.render(begin;#{compiled_source};end)"
    end

    def render(text)
      CommonMarker.render_html(text).html_safe
    end

    private

    def erb
      @erb ||= ActionView::Template.registered_template_handler(:erb)
    end
  end
end
