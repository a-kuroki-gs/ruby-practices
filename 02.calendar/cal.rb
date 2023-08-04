#!/usr/bin/env ruby

require 'date'
require 'optparse'
opt = OptionParser.new

option = {}
opt.on('-y') {|v| v}
opt.on('-m') {|v| v}

opt.parse!(ARGV, into: option)

if option[:y] == true && option[:m] == true
    @y = ARGV[0]
    @m = ARGV[1]
  elsif option[:y] == true
    @y = ARGV[0]
    @m = Date.today.month
  elsif option[:m] == true
    @y = Date.today.year
    @m = ARGV[0]
  else
    @y = Date.today.year
    @m = Date.today.month
end

def print_d(d)
  if d.saturday?
    puts "#{d.strftime('%e')}"
  else
    print "#{d.strftime('%e')} "
  end
end

def print_today(d)
  if d.saturday?
    puts "\e[30m\e[47m#{d.strftime('%e')}\e[0m "
  else
    print "\e[30m\e[47m#{d.strftime('%e')}\e[0m "
  end
end

def p_calender(year, month)
  puts "      #{month}月 #{year}"
  puts "日 月 火 水 木 金 土"
  
  first = Date.new(year, month, 1)
  last = Date.new(year, month, -1)
  days = (first..last)
  
  space_first = first.strftime('%w').to_i
  space_first.times do
    print "   "
  end
  
  days.each do |day|
    if day == Date.today
      print_today(day)
    else
      print_d(day)
    end
  end
  puts
  
end

@y = @y.to_i
@m = @m.to_i

if @y >= 1
  if @m >= 1 && @m <= 12
    p_calender(@y, @m)
  else
    puts "cal: #{@m} is neither a month number (1..12) nor a name"
  end
else
  if @y == 0
    puts "cal: year `0' not in range 1..9999"
  else
    "その他のエラー"
  end
end
