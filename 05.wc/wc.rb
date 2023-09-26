#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def count_lines(file, max_length)
  line_count = 0

  file.each_line do
    line_count += 1
  end

  max_length = [max_length, line_count.to_s.length].max

  [line_count, max_length]
end

def count_words(file, max_length)
  word_count = 0

  file.each_line do |l|
    word_array = l.split(' ')
    word_count += word_array.count
  end

  max_length = [max_length, word_count.to_s.length].max

  [word_count, max_length]
end

def count_bytes(file, max_length)
  byte_count = file.bytesize

  max_length = [max_length, byte_count.to_s.length].max

  [byte_count, max_length]
end

opt = OptionParser.new

params = {}
opt.on('-l') { |v| params[:l] = v }
opt.on('-w') { |v| params[:w] = v }
opt.on('-c') { |v| params[:c] = v }
opt.parse!(ARGV)

file_info_array = []

max_length = { lines: 0, words: 0, bytes: 0, path: 0 }

if ARGV.empty?
  file_info = { lines: nil, words: nil, bytes: nil, path: nil }

  file = $stdin.read

  file_info[:lines], max_length[:lines] = count_lines(file, max_length[:lines])
  file_info[:words], max_length[:words] = count_words(file, max_length[:words])
  file_info[:bytes], max_length[:bytes] = count_bytes(file, max_length[:bytes])

  max_length =
    if params.values.count(true) == 1
      0
    elsif max_length.values.max < 8
      7
    else
      0
    end

  file_info_array << file_info

else
  ARGV.each do |file_path|
    file_info = { lines: nil, words: nil, bytes: nil, path: nil }
    file = File.read(file_path.to_s)

    file_info[:lines], max_length[:lines] = count_lines(file, max_length[:lines])
    file_info[:words], max_length[:words] = count_words(file, max_length[:words])
    file_info[:bytes], max_length[:bytes] = count_bytes(file, max_length[:bytes])
    file_info[:path] = file_path

    file_info_array << file_info
  end

  if ARGV.count == 1
    max_length =
      if params.values.count(true) == 1
        0
      else
        max_length.values.max
      end
  else
    file_info_sum = { lines: 0, words: 0, bytes: 0, path: '合計' }
    max_length_of_sum = 0
    file_info_array.each do |info|
      file_info_sum[:lines] += info[:lines]
      file_info_sum[:words] += info[:words]
      file_info_sum[:bytes] += info[:bytes]

      max_length_of_sum = [max_length_of_sum, [file_info_sum[:lines], file_info_sum[:words], file_info_sum[:bytes]].max.to_s.length].max
    end
    file_info_array << file_info_sum
    max_length = [max_length.values.max, max_length_of_sum].max
  end
end

file_info_array.each do |info|
  if params[:l] || params.none?
    print info[:lines].to_s.rjust(max_length)
    print ' '
  end
  if params[:w] || params.none?
    print info[:words].to_s.rjust(max_length)
    print ' '
  end
  if params[:c] || params.none?
    print info[:bytes].to_s.rjust(max_length)
    print ' '
  end
  if info[:path]
    puts info[:path]
  else
    puts
  end
end
