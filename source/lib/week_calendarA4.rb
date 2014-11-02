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
  def initialize(year)
    @year = year
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

  def title
    @pdf.text_box "#{@year}\nWeeks", at: [12.5.cm, 3.cm + @page_height / 2],
                                     width: 6.cm, height: 1.cm, align: :right
  end

  def background_odd
    [@page_height / 2, 0].each do |y|
      @pdf.stamp_at 'dots', [@gutter_cm + @hmargin_cm - @dot_size_cm,
                             y + @vmargin_cm]
      thu_sun(y)
    end
    mid_page_mark
  end

  def background_even
    [@page_height / 2, 0].each do |y|
      @pdf.stamp_at 'dots', [@hmargin_cm - @dot_size_cm,
                             y + @vmargin_cm]
      mon_wed(y)
    end
    mid_page_mark
  end

  def mon_wed(y = 0)
    xd = 0
    ['mon', 'tue', 'wed'].each do |day|
      day_box day, @hmargin_cm + (5 + xd).cm, y + @page_height / 2 - @vmargin_cm
      xd += 6
    end
  end

  def thu_sun(y = 0)
    xd = - 6
    ['thu', 'fri', 'sat'].each do |day|
      xd += 6
      day_box day,
              @gutter_cm + @hmargin_cm + (5 + xd).cm,
              y + @page_height / 2 - @vmargin_cm
    end
    day_box 'sun',
            @gutter_cm + @hmargin_cm + (5 + xd).cm,
            y + @page_height / 2 - @vmargin_cm - 4.5.cm
  end

  def calendar_column_top(text, x = 0, y = 0)
    calendar_column_bottom(text, x, y + @page_height / 2)
  end

  def calendar_column_bottom(text, x = 0, y = 0)
    current_color = @pdf.fill_color
    calendar_lines = text.split("\n").size - 2
    @pdf.fill_color = 'FFFFFF' # "1177AA"
    @pdf.fill_rectangle([x + @page_width - @hmargin_cm - (@grid * 9.5).cm,
                         y + @vmargin_cm + (@grid * (calendar_lines + 0.5)).cm],
                        (@grid * 9).cm, (@grid * calendar_lines).cm)
    @pdf.fill_color = current_color
    @pdf.text_box text, at: [x + @page_width - @hmargin_cm - 6.cm,
                             y + @page_height / 2 - @vmargin_cm],
                        width: 5.85.cm, height: 12.cm,
                        inline_format: true,
                        align: :right, valign: :bottom,
                        leading: 1.15.mm,
                        overflow: :shrink_to_fit, min_font_size: 2
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

  def day_box(text, x = 0, y = 0)
    @pdf.text_box text, at: [x, y], width: 1.cm, height: 0.45.cm,
                        align: :center, valign: :center
  end

  def mid_page_mark
    @pdf.stroke do
      @pdf.horizontal_line 0, @page_width, at: @page_height / 2
    end
  end

  def method_missing(m, *args, &block)
    @pdf.send(m, *args, &block)
  end
end

def map_week_days(wweek)
  week = wweek.days.map { |d| format('%2d', d.mday) }.join('  ')
  case wweek.days.last.mday
  when 1..7
    "<color rgb='000000'>" +
    "#{week}  #{Date::MONTHNAMES[wweek.days.last.month][0]}</color>\n"
  when 8..14
    "#{week}  #{Date::MONTHNAMES[wweek.days.last.month][1]}\n"
  when 15..21
    "#{week}  #{Date::MONTHNAMES[wweek.days.last.month][2]}\n"
  else
    "#{week}   \n"
  end
end

page_width, page_height = PDF::Core::PageGeometry::SIZES['A4']
dot_size_cm = 0.015.cm
gutter_cm = 1.cm
hmargin_cm = 1.cm
vmargin_cm = 1.4.cm

year = Time.now.year
year_calendar = ''
p = PdfCalendar.new(Time.now.year)

# First page
p.title
p.mid_page_mark
p.stamp_at 'dots', [gutter_cm + hmargin_cm - dot_size_cm, vmargin_cm]
p.thu_sun
wweek = WorkingWeek.new(year, 0)
year_calendar << map_week_days(wweek)
calendar = WeekCalendar.new(wweek).pdf_text
p.calendar_column_bottom(calendar)

i = 1
while true
  wweek = WorkingWeek.new(year, i) rescue break

  p.start_new_page
  p.background_even

  p.start_new_page
  p.background_odd

  year_calendar << map_week_days(wweek)
  calendar = WeekCalendar.new(wweek).pdf_text
  p.calendar_column_top calendar
  i += 1
  wweek = WorkingWeek.new(year, i) rescue break
  year_calendar << map_week_days(wweek)
  calendar = WeekCalendar.new(wweek).pdf_text
  p.calendar_column_bottom(calendar)
  i += 1
end

p.start_new_page
p.font 'Inconsolata0.ttf', size: 6
p.mid_page_mark
[page_height / 2 , 0].each do |y|
  p.text_box year_calendar, at: [page_width - hmargin_cm - 6.cm,
                                 y + page_height / 2 - hmargin_cm],
                            width: 6.cm, height: page_height / 2 - hmargin_cm * 2,
                            inline_format: true,
                            align: :right, valign: :center,
                            overflow: :shrink_to_fit
end
p.render_file('calendarA4.pdf')
puts "Done in #{Time.now - STARTED_AT}s"
