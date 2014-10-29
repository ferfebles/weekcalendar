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

class PdfCalendar
  def initialize
    @pdf = Prawn::Document.new(page_size: 'A4', margin: 0)
    @pdf.font 'Inconsolata0.ttf', size: 10
    @pdf.fill_color '777777'
    @page_width, @page_height = PDF::Core::PageGeometry::SIZES['A4']
    @grid = 0.5
    @dot_size_cm = 0.015.cm
    @gutter_cm = 1.cm
    @hmargin_cm = 1.cm
    @vmargin_cm = 1.4.cm
    create_stamp_dots
    @pdf
  end

  def create_stamp_dots
    @pdf.create_stamp 'dots' do
      @pdf.fill_color = '555555'
      (0 .. 6 * 2).step(@grid) do |y|
        (0 .. 6 * 3).step(@grid) do |x|
          radius_cm = case
                      when x % 6 == 0
                        @dot_size_cm
                      when x % 1 == 0
                        @dot_size_cm / 2
                      else
                        @dot_size_cm / 3
                      end
          @pdf.fill_circle [x.cm + @dot_size_cm, y.cm + @dot_size_cm], radius_cm
        end
      end
    end
  end

  def calendar_text_box_bottom(text, y = 0)
    @pdf.text_box text, at: [@hmargin_cm + 12.75.cm, y + @vmargin_cm + 4.04.cm],
                        width: 6.cm, height: 4.cm,
                        inline_format: true,
                        align: :right, valign: :bottom,
                        leading: 1.15.mm,
                        overflow: :shrink_to_fit, min_font_size: 2
  end

  def calendar_text_box_top(text, y = 0)
    calendar_text_box_bottom(text, y + @page_height / 2)
  end

  def method_missing(m, *args, &block)
    @pdf.send(m, *args, &block)
  end
end

page_width, page_height = PDF::Core::PageGeometry::SIZES['A4']
grid = 0.5
dot_size_cm = 0.015.cm
gutter_cm = 1.cm
hmargin_cm = 1.cm
vmargin_cm = 1.4.cm

year = Time.now.year
year_calendar = ''
p = PdfCalendar.new

# First page

p.text_box "#{year}\nWeeks", at: [12.5.cm, 3.cm + page_height / 2],
                             width: 6.cm, height: 1.cm,
                             align: :right
p.stroke do
 p.horizontal_line 0, page_width, at: page_height / 2
end
p.stamp_at 'dots', [gutter_cm + hmargin_cm - dot_size_cm, vmargin_cm]
p.text_box 'thu', at: [gutter_cm + hmargin_cm + 5.cm, page_height / 2 - vmargin_cm],
                  width: 1.cm, height: 0.45.cm,
                  align: :center, valign: :center
p.text_box 'fri', at: [gutter_cm + hmargin_cm + 11.cm, page_height / 2 - vmargin_cm],
                  width: 1.cm, height: 0.45.cm,
                  align: :center, valign: :center
p.text_box 'sat', at: [gutter_cm + hmargin_cm + 17.cm, page_height / 2 - vmargin_cm],
                  width: 1.cm, height: 0.45.cm,
                  align: :center, valign: :center
p.text_box 'sun', at: [gutter_cm + hmargin_cm + 17.cm, page_height / 2 - vmargin_cm - 4.5.cm],
                  width: 1.cm, height: 0.45.cm,
                  align: :center, valign: :center
wweek = WorkingWeek.new(year, 0)
year_calendar << wweek.days.map { |d| format('%2d', d.mday) }.join('  ') + "\n"
calendar = WeekCalendar.new(wweek).pdf_text
p.text_box calendar, at: [hmargin_cm + 12.75.cm, vmargin_cm + 4.04.cm],
                     width: 6.cm, height: 4.cm,
                     inline_format: true,
                     align: :right, valign: :bottom,
                     leading: 1.15.mm

# Even pages
p.repeat(->(pg) { pg.even? && pg > 1 }) do
  p.stroke do
   p.horizontal_line 0, page_width, at: page_height / 2
  end

  p.stamp_at 'dots', [hmargin_cm - dot_size_cm, page_height / 2 + vmargin_cm]
  p.text_box 'mon', at: [hmargin_cm + 5.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'tue', at: [hmargin_cm + 11.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'wed', at: [hmargin_cm + 17.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center

  p.stamp_at 'dots', [hmargin_cm - dot_size_cm, vmargin_cm]
  p.text_box 'mon', at: [hmargin_cm + 5.cm, page_height / 2 - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'tue', at: [hmargin_cm + 11.cm, page_height / 2 - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'wed', at: [hmargin_cm + 17.cm, page_height / 2 - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
end

# Odd pages
p.repeat(->(pg) { pg.odd? && pg > 1 }) do
  p.stroke do
    p.horizontal_line 0, page_width, at: page_height / 2
  end

  p.stamp_at 'dots', [gutter_cm + hmargin_cm - dot_size_cm, page_height / 2 + vmargin_cm]
  p.text_box 'thu', at: [gutter_cm + hmargin_cm + 5.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'fri', at: [gutter_cm + hmargin_cm + 11.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'sat', at: [gutter_cm + hmargin_cm + 17.cm, page_height - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'sun', at: [gutter_cm + hmargin_cm + 17.cm, page_height - vmargin_cm - 4.5.cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center

  p.stamp_at 'dots', [gutter_cm + hmargin_cm - dot_size_cm, vmargin_cm]
  p.text_box 'thu', at: [gutter_cm + hmargin_cm + 5.cm, page_height / 2 - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'fri', at: [gutter_cm + hmargin_cm + 11.cm, page_height / 2 - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'sat', at: [gutter_cm + hmargin_cm + 17.cm, page_height / 2 - vmargin_cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
  p.text_box 'sun', at: [gutter_cm + hmargin_cm + 17.cm, page_height / 2 - vmargin_cm - 4.5.cm],
                    width: 1.cm, height: 0.45.cm,
                    align: :center, valign: :center
end

i = 1
while true
  p.start_new_page
  p.start_new_page
  wweek = WorkingWeek.new(year, i) rescue break
  year_calendar << wweek.days.map { |d| format('%2d', d.mday) }.join('  ') + "\n"
  calendar = WeekCalendar.new(wweek).pdf_text
  p.calendar_text_box_top calendar
  i += 1
  wweek = WorkingWeek.new(year, i) rescue break
  year_calendar << wweek.days.map { |d| format('%2d', d.mday) }.join('  ') + "\n"
  calendar = WeekCalendar.new(wweek).pdf_text
  p.calendar_text_box_bottom(calendar)
  i += 1
end

p.start_new_page
p.text_box year_calendar, at: [hmargin_cm + 11.75.cm, page_height - vmargin_cm],
                       width: 6.cm, height: page_height / 2 - vmargin_cm * 2,
                       inline_format: true,
                       align: :right, valign: :bottom,
                       overflow: :shrink_to_fit, min_font_size: 2
puts "Done in #{Time.now - STARTED_AT}s"
