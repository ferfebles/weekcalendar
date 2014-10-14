STARTED_AT = Time.now
require_relative 'working_week'
require 'prawn'
require 'prawn/measurement_extensions'

# Returns a pdf formatted string with the
# month calendar, for the provided working_week
class WeekCalendar
  def initialize(wweek)
    @wweek = wweek
  end

  def pdf_text
    Date::MONTHNAMES[@wweek.month] +
    @wweek.month_calendar.map do |day|
      current_week?(day) ? d_style(tag(day)) : tag(day)
    end.join
  end

  def current_week?(day)
    @wweek.days.include? day
  end

  def d_style(text)
    "<color rgb='000000'>" + text + '</color>'
  end

  def tag(day)
    (day.monday? ? "\n" : '  ') +
    format('%2d', day.mday)
  end
end

page_height, page_width = PDF::Core::PageGeometry::SIZES['A5']
grid = 0.5
dot_size_cm = 0.015.cm
gutter_cm = 1.cm
hmargin_cm = 1.cm
vmargin_cm = 1.4.cm

year = Time.now.year
Prawn::Document.generate('calendar.pdf',
                         page_size: 'A5',
                         page_layout: :landscape,
                         margin: 0) do
  font 'Inconsolata0.ttf', size: 10
  fill_color '777777'
  text_box "#{year}\nWeeks", at: [12.5.cm, 3.cm],
                             width: 6.cm, height: 1.cm,
                             align: :right

  create_stamp 'dots' do
    self.fill_color = '555555'
    (0 .. 6 * 2).step(grid) do |y|
      (0 .. 6 * 3).step(grid) do |x|
        radius_cm = case
                    when x % 6 == 0
                      dot_size_cm
                    when x % 1 == 0
                      dot_size_cm / 2
                    else
                      dot_size_cm / 3
                    end
        fill_circle [x.cm + dot_size_cm, y.cm + dot_size_cm], radius_cm
      end
    end
  end

  repeat(->(pg) { pg.even? && pg > 1 }) do
    text_box 'mon', at: [hmargin_cm + 5.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
    text_box 'tue', at: [hmargin_cm + 11.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
    text_box 'wed', at: [hmargin_cm + 17.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
    stamp_at 'dots', [hmargin_cm - dot_size_cm, vmargin_cm]
  end

  repeat(->(pg) { pg.odd? && pg > 2 }) do
    text_box 'thu', at: [gutter_cm + hmargin_cm + 5.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
    text_box 'fri', at: [gutter_cm + hmargin_cm + 11.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
    text_box 'sat', at: [gutter_cm + hmargin_cm + 17.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
    text_box 'sun', at: [gutter_cm + hmargin_cm + 17.cm, page_height - vmargin_cm - 4.5.cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
    stamp_at 'dots', [gutter_cm + hmargin_cm - dot_size_cm, vmargin_cm]
  end
  100.times do |i|
    wweek = WorkingWeek.new(year, i) rescue break
    start_new_page
    start_new_page
    calendar = WeekCalendar.new(wweek).pdf_text
    # puts calendar + "\n"
    text_box calendar, at: [hmargin_cm + 12.75.cm, vmargin_cm + 4.04.cm],
                       width: 6.cm, height: 4.cm,
                       inline_format: true,
                       align: :right, valign: :bottom,
                       leading: 1.15.mm

  end
end
puts "Done in #{Time.now - STARTED_AT}s"
