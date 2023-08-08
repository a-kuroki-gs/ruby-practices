#!/usr/bin/env ruby

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

frames1 = frames.take(9)
frames2 = frames.drop(9)

point = 0
p_plus = 0
frames1.each do |frame|
  point += frame.sum
  case p_plus
  when 4
    point += frame[0]
    point += frame.sum
  when 2
    point += frame.sum
  when 1
    point += frame[0]
  end
  p_plus =
    if frame[0] == 10
      [2, 4].include?(p_plus) ? 4 : 2
    elsif frame.sum == 10
      1
    else
      0
    end
end

case p_plus
when 4
  if frames2[0] == [10, 0]
    point += 20
    point += frames2[1].first
  else
    point += frames2[0].sum + frames2[0].first
  end
when 2
  if frames2[0] == [10, 0]
    point += 10
    point += frames2[1].first
  else
    point += frames2[0].sum
  end
when 1
  point += frames2[0].first
end

frames2.each do |frame|
  point += frame.sum
end

puts point
