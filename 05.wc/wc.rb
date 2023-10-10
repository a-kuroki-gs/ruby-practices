#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def calculate_max_length(count_number, max_length)
  [max_length, count_number.to_s.length].max
end

def get_file_info(file, max_lengths_of_data_size)
  file_info = { lines: 0, words: 0, bytes: 0, path: nil }

  file.each_line do |l|
    file_info[:lines] += 1
    word_array = l.split(' ')
    file_info[:words] += word_array.count
  end
  file_info[:bytes] = file.bytesize

  max_lengths_of_data_size[:lines] = calculate_max_length(file_info[:lines], max_lengths_of_data_size[:lines])
  max_lengths_of_data_size[:words] = calculate_max_length(file_info[:words], max_lengths_of_data_size[:words])
  max_lengths_of_data_size[:bytes] = calculate_max_length(file_info[:bytes], max_lengths_of_data_size[:bytes])

  [file_info, max_lengths_of_data_size]
end

def get_max_length_of_stdin(params, max_lengths_of_data_size)
  if params.values.count(true) == 1
    0
  elsif max_lengths_of_data_size.values.max < 8
    7
  else
    max_lengths_of_data_size.values.max - 2
  end
end

def get_max_length_of_file(params, max_lengths_of_data_size)
  if params.values.count(true) == 1
    0
  else
    max_lengths_of_data_size.values.max
  end
end

def get_sum_info(file_infos)
  file_info_sum = { lines: 0, words: 0, bytes: 0, path: '合計' }
  max_length_of_sum = 0
  file_infos.each do |info|
    file_info_sum[:lines] += info[:lines]
    file_info_sum[:words] += info[:words]
    file_info_sum[:bytes] += info[:bytes]

    max_length_of_sum = [max_length_of_sum, [file_info_sum[:lines], file_info_sum[:words], file_info_sum[:bytes]].max.to_s.length].max
  end
  file_infos << file_info_sum

  [file_infos, max_length_of_sum]
end

opt = OptionParser.new

params = {}
opt.on('-l') { |v| params[:l] = v }
opt.on('-w') { |v| params[:w] = v }
opt.on('-c') { |v| params[:c] = v }
opt.parse!(ARGV)

file_infos = []
string_lengths_of_data_size = { lines: 0, words: 0, bytes: 0, path: 0 }

if ARGV.empty?
  file_info, string_lengths_of_data_size = get_file_info($stdin.read, string_lengths_of_data_size)
  file_infos << file_info

  string_length = get_max_length_of_stdin(params, string_lengths_of_data_size)

else
  ARGV.each do |file_path|
    file_info, string_lengths_of_data_size = get_file_info(File.read(file_path), string_lengths_of_data_size)
    file_info[:path] = file_path
    file_infos << file_info
  end

  if ARGV.count == 1
    string_length = get_max_length_of_file(params, string_lengths_of_data_size)
  else
    file_infos, string_length_of_sum = get_sum_info(file_infos)
    string_length = [string_lengths_of_data_size.values.max, string_length_of_sum].max
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
