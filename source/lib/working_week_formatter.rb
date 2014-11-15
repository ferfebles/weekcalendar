require 'date'

# Returns a string with the working week
# formatted for month or year calendars
# in a pdf document
#
class WorkingWeekFormatter
  def initialize(wweek)
    @wweek = wweek
  end

  def to_month_calendar
    Date::MONTHNAMES[@wweek.month] +
    @wweek.month_calendar.map do |day|
      current_week?(day) ? black_text(tag(day)) : tag(day)
    end.join
  end

  def to_year_calendar
    week = @wweek.days.map { |d| format('%2d', d.mday) }.join('  ')
    sunday = @wweek.days.last
    case
    when (1..7).include?(sunday.mday) && sunday.year == @wweek.year
      black_text("#{week}  #{Date::MONTHNAMES[@wweek.days.last.month][0]}")
    when (8..14).include?(sunday.mday)
      dark_grey_text("#{week}  #{Date::MONTHNAMES[@wweek.days.last.month][1]}")
    when (15..21).include?(sunday.mday)
      dark_grey_text("#{week}  #{Date::MONTHNAMES[@wweek.days.last.month][2]}")
    else
      dark_grey_text("#{week}   ")
    end
  end

  #--------------------------------------------------

  private

  def current_week?(day)
    @wweek.days.include? day
  end

  def black_text(text)
    colored_text(text, '000000')
  end

  def dark_grey_text(text)
    colored_text(text, '444444')
  end

  def colored_text(text, colour)
    "<color rgb='#{colour}'>" + text + '</color>'
  end

  def tag(day)
    (day.monday? ? "\n" : '  ') + format('%2d', day.mday)
  end
end
