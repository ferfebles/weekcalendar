require 'date'
require 'prawn'
require 'prawn/measurement_extensions'
require 'pry'

# printing calendars
class Calendar

  class Week
    def initialize()
    end
  end

  def first_week
  end

  def print_month(year, month)
    first = Date.new(year, month, 1)
    last = first.next_month.prev_day
    first_monday = first - (first.wday == 0 ? 6 : first.wday - 1)
    last_sunday = last + (7 - last.wday) % 7
    ret = ''
    first_monday.upto(last_sunday) do |day|
        ret << '%2d  ' % day.mday
        ret.rstrip! << "\n" if day.wday == 0
    end
    ret
  end
end

puts Calendar.new.print_month(2007, 3)

page_height, page_width = PDF::Core::PageGeometry::SIZES['A5']
grid = 0.5
dot_size_cm = 0.015.cm
gutter_cm = 1.cm
hmargin_cm = 1.cm
vmargin_cm = 1.4.cm

Prawn::Document.generate('calendar.pdf',
                         page_size: 'A5',
                         page_layout: :landscape,
                         margin: 0) do
  # stroke_axis(at: [1.cm, 1.cm], step_length: 0.5.cm, negative_axes_length: 1.cm)

  create_stamp 'dots' do
    self.fill_color = '777777'
    (0 .. 6 * 2).step(grid) do |y|
      (0 .. 6 * 3).step(grid) do |x|
        radius_cm = case
        when x % 6 == 0
          dot_size_cm
        when x % 1 == 0
          dot_size_cm / 2
        else
          dot_size_cm / 4
        end
        fill_circle [x.cm + dot_size_cm, y.cm + dot_size_cm], radius_cm
      end
    end
  end

  repeat :odd do
    draw_text 'Mon', at: [0.5.cm, 10.5.cm]
    stamp_at 'dots', [gutter_cm + hmargin_cm - dot_size_cm, vmargin_cm]
  end

  repeat :even do
    draw_text 'Thu', at: [0.5.cm, 10.5.cm]
    stamp_at 'dots', [hmargin_cm - dot_size_cm, vmargin_cm]
  end

  10.times do |week|
    start_new_page
    calendar = "<font name='Courier' size='7'><color rgb='0000ff'>Jan  </color>"
    calendar << Calendar.new.print_month(2007, 3)
    calendar << '</font>'

    text_box calendar, at: [12.5.cm, 6.75.cm],
                       width: 6.cm, height: 4.cm,
                       overflow: :shrink_to_fit,
                       min_font_size: 2,
                       inline_format: true,
                       align: :right,
                       leading: 2.4.mm
  end
end
