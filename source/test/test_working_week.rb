require_relative 'test_helper'
require_relative '../lib/working_week'

require 'pry'

# WorkingWeek starts on monday
class TestWorkingWeek < Minitest::Test
  def setup
    @ww2014_01 = WorkingWeek.new(2014, 1)
    @ww2011_27 = WorkingWeek.new(2011, 27)
    @ww2012_01 = WorkingWeek.new(2012, 1)
    @ww2012_06 = WorkingWeek.new(2012, 6)
    @ww2012_09 = WorkingWeek.new(2012, 9)
    @ww2012_53 = WorkingWeek.new(2012, 53)
    @working_weeks = [@ww2014_01, @ww2011_27, @ww2012_01, @ww2012_06,
                      @ww2012_09, @ww2012_53]
  end

  def test_days
    @working_weeks.each do |wweek|
      assert wweek.days.first.monday?
      assert wweek.days.last.sunday?
    end
  end

  def test_month
    assert_equal 1, @ww2014_01.month
    assert_equal 7, @ww2011_27.month
    assert_equal 1, @ww2012_01.month
    assert_equal 2, @ww2012_06.month
    assert_equal 2, @ww2012_09.month
    puts @ww2012_53.days
    assert_equal 12, @ww2012_53.month
  end

  def test_month_calendar
    @working_weeks.each do |wweek|
      first_monday = wweek.month_calendar.first
      first_sunday = first_monday + 6
      assert first_monday.monday?
      assert((first_monday..first_sunday).find { |day| day.mday == 1 })
      last_sunday = wweek.month_calendar.last
      last_monday = last_sunday - 6
      assert last_sunday.sunday?
      assert_equal((first_sunday).month, (last_monday).month)
    end
  end
end
