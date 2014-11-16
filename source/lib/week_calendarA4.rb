STARTED_AT = Time.now

require_relative 'working_week'
require_relative 'working_week_formatter'
require 'prawn'
require 'prawn/measurement_extensions'

class CalendarDocument < Prawn::Document
  def initialize(year)
    @year = year
    super(page_size: 'A4', margin: 0)
    font 'Inconsolata0.ttf', size: 10
    fill_color '777777'
    @page_width, @page_height = PDF::Core::PageGeometry::SIZES['A4']
    @grid = 0.5
    @dot_size_cm = 0.01.cm
    @gutter_cm = 1.cm
    @hmargin_cm = 1.cm
    @vmargin_cm = 1.4.cm
    create_stamp_dots
  end

  attr_accessor :page_width, :page_height, :gutter_cm,
                :hmargin_cm, :vmargin_cm, :dot_size_cm

  def title
    text_box "#{@year}\nWeeks", at: [12.5.cm, 3.cm + @page_height / 2],
                                width: 6.cm, height: 1.cm, align: :right
  end

  def background_odd
    [@page_height / 2, 0].each do |y|
      stamp_at 'dots', [@gutter_cm + @hmargin_cm - @dot_size_cm,
                        y + @vmargin_cm]
      thu_sun(y)
    end
    mid_page_mark
  end

  def background_even
    [@page_height / 2, 0].each do |y|
      stamp_at 'dots', [@hmargin_cm - @dot_size_cm,
                        y + @vmargin_cm]
      mon_wed(y)
    end
    mid_page_mark
  end

  def mon_wed(y = 0)
    xd = 0
    ['mon', 'tue', 'wed'].each do |day|
      day_box day, @hmargin_cm + (5 + xd).cm,
              y + @page_height / 2 - @vmargin_cm
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
    current_color = fill_color
    calendar_lines = text.split("\n").size - 2
    self.fill_color = 'FFFFFF'
    fill_rectangle([x + @page_width - @hmargin_cm - (@grid * 9.5).cm,
                    y + @vmargin_cm + (@grid * (calendar_lines + 0.5)).cm],
                   (@grid * 9).cm, (@grid * calendar_lines).cm)
    self.fill_color = current_color
    text_box text, at: [x + @page_width - @hmargin_cm - 6.05.cm,
                        y + @page_height / 2 - @vmargin_cm],
                   width: 5.85.cm, height: 12.cm,
                   inline_format: true,
                   align: :right, valign: :bottom,
                   leading: 1.15.mm,
                   overflow: :shrink_to_fit, min_font_size: 2
  end

  def create_stamp_dots(name = 'dots', width = 6 * 3, height = 6 * 2)
    create_stamp name do
      self.fill_color = '555555'
      (0 .. height).step(@grid) do |y|
        (0 .. width).step(@grid) do |x|
          radius_cm = case
                      when x % 6 == 0
                        @dot_size_cm
                      when x % 1 == 0
                        @dot_size_cm / 2
                      else
                        @dot_size_cm / 3
                      end
          fill_circle [x.cm + @dot_size_cm, y.cm + @dot_size_cm], radius_cm
        end
      end
    end
  end

  def day_box(text, x = 0, y = 0)
    text_box text, at: [x, y], width: (@grid * 2).cm,
                   height: (@grid + 0.05).cm,
                   align: :center, valign: :center
  end

  def mid_page_mark
    stroke do
      stroke_color 'AAAAAA'
      line_width 0.1
      horizontal_line 0, @hmargin_cm * 2,
                      at: @page_height / 2
      horizontal_line @page_width - @hmargin_cm * 2, @page_width,
                      at: @page_height / 2
    end
  end
end

year = (ARGV[0] || Time.now.year).to_i
year_calendar = []
p = CalendarDocument.new(year)

# First page
p.title
p.mid_page_mark
p.stamp_at 'dots', [p.gutter_cm + p.hmargin_cm - p.dot_size_cm, p.vmargin_cm]
p.thu_sun
wweek = WorkingWeek.new(year, 0)
ww_formatter = WorkingWeekFormatter.new(wweek)
p.calendar_column_bottom(ww_formatter.to_month_calendar)
year_calendar << ww_formatter.to_year_calendar

i = 1
while true
  wweek = WorkingWeek.new(year, i) rescue break

  p.start_new_page
  p.background_even

  p.start_new_page
  p.background_odd

  ww_formatter = WorkingWeekFormatter.new(wweek)
  p.calendar_column_top ww_formatter.to_month_calendar
  year_calendar << ww_formatter.to_year_calendar
  i += 1
  wweek = WorkingWeek.new(year, i) rescue break
  ww_formatter = WorkingWeekFormatter.new(wweek)
  p.calendar_column_bottom ww_formatter.to_month_calendar
  year_calendar << ww_formatter.to_year_calendar
  i += 1
end

year_calendar = year_calendar.join("\n")
p.font 'Inconsolata0.ttf', size: 6
p.create_stamp_dots('dots_year', 14.5, 12)
[0, p.gutter_cm].each do |x|
  p.start_new_page
  p.mid_page_mark
  [p.page_height / 2 , 0].each do |y|
    p.stamp_at('dots_year', [x + p.hmargin_cm, y + p.vmargin_cm])
    p.text_box year_calendar, at: [x + p.page_width - p.hmargin_cm - 7.cm,
                                   y + p.page_height / 2 - p.hmargin_cm],
                              width: 6.cm, height: p.page_height / 2 - p.hmargin_cm * 2,
                              inline_format: true,
                              align: :right, valign: :center
  end
end
p.render_file("calendars/calendarA4_#{year}.pdf")
`open "calendars/calendarA4_#{year}.pdf"`
puts "Done in #{Time.now - STARTED_AT}s"
