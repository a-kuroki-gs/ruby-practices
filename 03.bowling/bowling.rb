#!/usr/bin/env ruby
# frozen_string_literal: true

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

frames = shots.each_slice(2).to_a
frames_1_9 = frames.take(9)
frames_10 = frames.drop(9)

point = 0
prev_frames = :normal
frames_1_9.each do |frame|
  point += frame.sum
  case prev_frames
  when :double
    point += frame[0]
    point += frame.sum
  when :strike
    point += frame.sum
  when :spare
    point += frame[0]
  end
  prev_frames =
    if frame[0] == 10
      [:double, :strike].include?(prev_frames) ? :double : :strike
    elsif frame.sum == 10
      :spare
    else
      :normal
    end
end

case prev_frames
when :double
  if frames_10[0] == [10, 0]
    point += 20
    point += frames_10[1].first
  else
    point += frames_10[0].sum + frames_10[0].first
  end
when :strike
  if frames_10[0] == [10, 0]
    point += 10
    point += frames_10[1].first
  else
    point += frames_10[0].sum
  end
when :spare
  point += frames_10[0].first
end

frames_10.each do |frame|
  point += frame.sum
end

puts point
