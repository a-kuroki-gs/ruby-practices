#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'
opt = OptionParser.new

option = {}
opt.on('-y VAL') { |v| option[:y] = v }
opt.on('-m VAL') { |v| option[:m] = v }

opt.parse!(ARGV)

y = option[:y].nil? ? Date.today.year.to_i : option[:y].to_i
m = option[:m].nil? ? Date.today.month.to_i : option[:m].to_i

def print_day(date)
  print date == Date.today ? "\e[7m#{date.day.to_s.rjust(2)}\e[0m " : date.day.to_s.rjust(2) + ' '
  puts if date.saturday?
end

def print_calender(year, month)
  puts "      #{month}月 #{year}"
  puts '日 月 火 水 木 金 土'

  first = Date.new(year, month, 1)
  last = Date.new(year, month, -1)
  days = (first..last)

  offset = first.wday
  print '   ' * offset

  days.each do |day|
    print_day(day)
  end
  puts
end

if y >= 1
  if m >= 1 && m <= 12
    print_calender(y, m)
  else
    puts "cal: #{m} is not a month number (1..12)"
  end
else
  puts '不正な入力です'
end
