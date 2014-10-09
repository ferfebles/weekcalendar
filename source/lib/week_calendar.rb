STARTED_AT = Time.now
require_relative 'working_week'
require 'prawn'
require 'prawn/measurement_extensions'

# Returns a string with the month
# for the provided working_week
class WeekCalendar
  def initialize(wweek, mark = '-')
    @wweek = wweek
    @mark = mark
  end

  def text
    Date::MONTHNAMES[@wweek.month] +
    @wweek.month_calendar.map do |day|
      (day.monday? ? left_margin(day) : '  ') +
      format('%2d', day.mday)
    end.join
  end

  def left_margin(day)
    if @wweek.days.first == day
      "\n#{@mark} "
    else
      "\n  "
    end
  end
end

year = Time.now.year
100.times do |i|
  wweek = WorkingWeek.new(year, i) rescue break
  puts WeekCalendar.new(wweek).text
  puts
end
puts "Done in #{Time.now - STARTED_AT}s"

Prawn::Document.generate('calendar.pdf',
                         page_size: 'A5',
                         page_layout: :landscape,
                         margin: 0) do

  100.times do |i|
    wweek = WorkingWeek.new(year, i) rescue break
    start_new_page
    calendar = "<font name='Courier' size='7'>"
    calendar << WeekCalendar.new(wweek).text
    calendar << '</font>'
    text_box calendar, at: [12.5.cm, 6.75.cm],
                       width: 6.cm, height: 4.cm,
                       overflow: :shrink_to_fit,
                       min_font_size: 2,
                       inline_format: true,
                       align: :right,
                       leading: 2.4.mm

  end
  puts "Done in #{Time.now - STARTED_AT}s"
end
