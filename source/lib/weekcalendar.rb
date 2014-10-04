require 'date'
require 'pry'
require 'pp'

year = Time.now.year
first = Date.new(year, 1, 1)
day = first - (first.cwday - 1)
month = 1
week = 0
#calendar = Array.new() { Array.new() { Array.new() } }
calendar = Hash.new(nil)
while true
  while true
    calendar[[month, week, (day.wday - 1) % 7]] = day
    day += 1
    if day.monday?
      break if (month < day.month) || (year < day.year)
      week += 1
    end
  end
  break if month == 12
  day = calendar[[month, week, 0]] unless day.monday? && day.mday == 1
  month += 1
  week = 0
end

calendar.each_key do |m, w, d|
  if d == 0
    puts "\n"
    puts "\n#{m}\n" if w == 0
  end
  print '%2d  ' % calendar[[m, w, d]].mday
end
puts "\n\n"

=begin
      calendar =[[d1, d2, d3, d4, d5, d6, d7],
                 [d1, d2, d3, d4, d5, d6, d7],
                 [d1, d2, d3, d4, d5, d6, d7],
                 [d1, d2, d3, d4, d5, d6, d7],
                 [d1, d2, d3, d4, d5, d6, d7],
                ]

      w = 0
      m = 0
      loop {
        DibujarMes(m, w, calendar)
        w += 1
        if calendar(m,w).nil?
          w = calendar(m,w,0).monday? ? 0 : 1
          m += 1
          exit if m == 12
        end
      }
=end