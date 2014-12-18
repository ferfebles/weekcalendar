STARTED_AT = Time.now

require_relative 'working_week'
require_relative 'working_week_formatter'
require 'prawn'
require 'prawn/measurement_extensions'

# Used to simplify document creation
class CalendarDocument < Prawn::Document
  def initialize(year)
    @year = year
    super(page_size: 'A5', margin: 0, page_layout: :landscape)
    font 'Inconsolata0.ttf', size: 10
    fill_color '777777'
    @page_height, @page_width = PDF::Core::PageGeometry::SIZES['A5']
    @grid = 0.5
    @dot_size_cm = 0.01.cm
    @gutter_cm = @hmargin_cm = 1.cm
    @vmargin_cm = 1.4.cm
    create_stamp_dots
  end

  attr_accessor :page_width, :page_height, :gutter_cm,
                :hmargin_cm, :vmargin_cm, :dot_size_cm

  def title
    text_box "#{@year}\nWeeks", at: [12.5.cm, 3.cm],
                                width: 6.cm, height: 1.cm, align: :right
  end

  def background_odd
    stamp_at 'dots', [@gutter_cm + @hmargin_cm - @dot_size_cm, @vmargin_cm]
    thu_sun
  end

  def background_even
    stamp_at 'dots', [@hmargin_cm - @dot_size_cm, @vmargin_cm]
    mon_wed
  end

  def mon_wed
    [['mon', 5], ['tue', 11], ['wed', 17]].each do |day|
      day_box day, @hmargin_cm + x.cm, @page_height - @vmargin_cm
    end
  end

  def thu_sun
    [['thu', 5], ['fri', 11], ['sat', 17]].each do |day, x|
      day_box day,
              @gutter_cm + @hmargin_cm + x.cm,
              @page_height - @vmargin_cm
    end
    day_box 'sun',
            @gutter_cm + @hmargin_cm + 17.cm,
            @page_height - @vmargin_cm - 4.5.cm
  end

  def calendar_column(text)
    current_color = fill_color
    calendar_lines = text.split("\n").size - 2
    self.fill_color = 'ffffff'
    fill_rectangle([@page_width - @hmargin_cm - (@grid * 9.5).cm,
                    @vmargin_cm + (@grid * (calendar_lines + 0.5)).cm],
                   (@grid * 9).cm, (@grid * calendar_lines).cm)
    self.fill_color = current_color
    text_box text, at: [@page_width - @hmargin_cm - 6.05.cm,
                        @page_height - @vmargin_cm],
                   width: 5.85.cm, height: 12.cm,
                   inline_format: true,
                   align: :right, valign: :bottom,
                   leading: 1.15.mm,
                   overflow: :shrink_to_fit, min_font_size: 2
  end

  def create_stamp_dots(name = 'dots', width = 6 * 3, height = 6 * 2)
    create_stamp name do
      self.fill_color = '555555'
      (0..height).step(@grid) do |y|
        (0..width).step(@grid) do |x|
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
end

year = (ARGV[0] || Time.now.year).to_i
year_calendar = []
p = CalendarDocument.new(year)

# First page
p.title

# Calendar pages
i = 0
loop do
  wweek = WorkingWeek.new(year, i) rescue break

  p.start_new_page
  p.background_even

  p.start_new_page
  p.background_odd

  ww_formatter = WorkingWeekFormatter.new(wweek)
  p.calendar_column ww_formatter.to_month_calendar
  year_calendar << ww_formatter.to_year_calendar
  i += 1
end

# Blank even page
p.start_new_page

# Year view pages
year_calendar = year_calendar.join("\n")
p.font 'Inconsolata0.ttf', size: 6
p.create_stamp_dots('dots_year', 14.5, 12)
3.times do
  [0, p.gutter_cm].each do |x|
    p.start_new_page
    [p.page_height, 0].each do |y|
      p.stamp_at('dots_year', [x + p.hmargin_cm, y + p.vmargin_cm])
      p.text_box year_calendar, at: [x + p.page_width - p.hmargin_cm - 7.cm,
                                     y + p.page_height - p.hmargin_cm],
                                width: 6.cm, height: p.page_height - p.hmargin_cm * 2,
                                inline_format: true,
                                align: :right, valign: :center
    end
  end
end
p.render_file("calendars/calendarA5_#{year}.pdf")
`cmd /c start "" """calendars/calendarA5_#{year}.pdf"`
