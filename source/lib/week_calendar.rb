STARTED_AT = Time.now
require_relative 'working_week'

year = Time.now.year
100.times { |i|
  wweek = WorkingWeek.new(year, i) rescue break
  print Date::MONTHNAMES[wweek.month]
  #print month: wweek.month, week: i
  #puts days: wweek.days
  wweek.month_calendar.each { |day|
    if day.monday?
      if wweek.days.first == day
        print "\n> "
      else
        print "\n  "
      end
    end
    print "%2d  " % day.mday
  }
  puts "\n\n"
}
puts "Done in #{Time.now - STARTED_AT}s"
