# Based on
# - https://github.com/metabolize/anafanafo/tree/main
# - https://github.com/badges/shields/blob/master/badge-maker/lib/badge-renderers.js
class BadgesController < ApplicationController

  PADDING = 5
  SCALE_UP_FACTOR = 10
  SCALE_DOWN_FACTOR = 0.1

  COLORS = {
    gray: "#555",
    blue: "#007ec6"
  }

  def reviewed_by
    n_reviews = Paper.visible.where(":reviewer = ANY (reviewers)", reviewer: params[:reviewer]).count
    @key = string_item("JOSS Reviews", COLORS[:gray])
    @value = string_item(n_reviews.to_s, COLORS[:blue], @key[:outer_width])
    @badge_width = @key[:outer_width] + @value[:outer_width]

    render template: 'badges/badge', locals: {
      scale_up_factor: SCALE_UP_FACTOR,
      scale_down_factor: SCALE_DOWN_FACTOR
    }
  end

  private

  def string_item(str, color, offset=0)
    # Object that contains templating information for rendering a string within a badge
    width = string_width(str)
    {
      text_width: width,
      outer_width: width + PADDING * 2,
      x: text_x_position(width, offset),
      text: str,
      color: color
    }
  end

  def string_width(data)
    data.to_s.codepoints.reduce(0) do |total, point|
      char_width = point < VERDANA_WIDTHS.length ? VERDANA_WIDTHS[point] : em_width
      total + char_width * SCALE_DOWN_FACTOR
    end
  end

  def text_x_position(width, offset=0)
    SCALE_UP_FACTOR * (offset + PADDING + width * 0.5)
  end

  def em_width
    VERDANA_WIDTHS["m".codepoints[0]]
  end
end
