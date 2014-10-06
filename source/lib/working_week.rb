
# A WorkingWeek start always on monday
# the first wweek of the year is the wweek 0
# wweek 0 is the week that includes January 1st
# wweek 0 can include days from the previous year
# the last wweek is the one that includes December 31st
# the last wweek can include days from the next year
class WorkingWeek
  def initialize(year, week_number)
    @year = year
    @monday = first_monday_of_weekyear(year) + week_number * 7
  end

  def days
    (@monday..(@monday + 6))
  end

  # A week can be splitted between two months
  # but a working week belongs to the month with more
  # working days for that working week.
  # This is the month that the Wednesday belongs to.
  # With two exceptions:
  #   - the first week of the year always belongs to January
  #   - the last week of the year always belongs to December
  def month
    sunday = @monday + 6
    return 1 if sunday.month == 1 && sunday.year == @year
    return 12 if @monday.month == 12 && @monday.year == @year
    (@monday + 2).month
  end

  #--------------------------------------------------

  private

  def first_monday_of_weekyear(year)
    first_day_of_year = Date.new(year, 1, 1)
    first_day_of_year - (first_day_of_year.cwday - 1)
  end
end
