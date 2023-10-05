#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def get_line_info(file, max_length)
  line_count = 0

  file.each_line do
    line_count += 1
  end

  max_length = [max_length, line_count.to_s.length].max

  [line_count, max_length]
end

def get_word_info(file, max_length)
  word_count = 0

  file.each_line do |l|
    word_array = l.split(' ')
    word_count += word_array.count
  end

  max_length = [max_length, word_count.to_s.length].max

  [word_count, max_length]
end

def get_byte_info(file, max_length)
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

file_infos = []

max_length = { lines: 0, words: 0, bytes: 0, path: 0 }

def get_file_info(file, max_length)
  file_info = { lines: nil, words: nil, bytes: nil, path: nil }

  file_info[:lines], max_length[:lines] = get_line_info(file, max_length[:lines])
  file_info[:words], max_length[:words] = get_word_info(file, max_length[:words])
  file_info[:bytes], max_length[:bytes] = get_byte_info(file, max_length[:bytes])

  [file_info, max_length]
end

def get_string_length_of_stdin(params, max_length)
  if params.values.count(true) == 1
    0
  elsif max_length.values.max < 8
    7
  else
    max_length.values.max - 2
  end
end

def get_string_length_of_file(params, max_length)
  if params.values.count(true) == 1
    0
  else
    max_length.values.max
  end
end

def get_sum_info(file_infos)
  file_info_sum = { lines: 0, words: 0, bytes: 0, path: '合計' }
  string_length_of_sum = 0
  file_infos.each do |info|
    file_info_sum[:lines] += info[:lines]
    file_info_sum[:words] += info[:words]
    file_info_sum[:bytes] += info[:bytes]

    string_length_of_sum = [string_length_of_sum, [file_info_sum[:lines], file_info_sum[:words], file_info_sum[:bytes]].max.to_s.length].max
  end
  file_infos << file_info_sum

  [file_infos, string_length_of_sum]
end

if ARGV.empty?
  file_info, max_length = get_file_info($stdin.read, max_length)
  file_infos << file_info

  string_length = get_string_length_of_stdin(params, max_length)

else
  ARGV.each do |file_path|
    file_info, max_length = get_file_info(File.read(file_path), max_length)
    file_info[:path] = file_path
    file_infos << file_info
  end

  if ARGV.count == 1
    string_length = get_string_length_of_file(params, max_length)
  else
    file_infos, string_length_of_sum = get_sum_info(file_infos)
    string_length = [max_length.values.max, string_length_of_sum].max
  end
end

file_infos.each do |info|
  if params[:l] || params.none?
    print info[:lines].to_s.rjust(string_length)
    print ' '
  end
  if params[:w] || params.none?
    print info[:words].to_s.rjust(string_length)
    print ' '
  end
  if params[:c] || params.none?
    print info[:bytes].to_s.rjust(string_length)
    print ' '
  end
  puts info[:path]
end
