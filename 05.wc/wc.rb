#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def calculate_max_length(count_number, max_length)
  [max_length, count_number.to_s.length].max
end

def find_file_data_and_max_lengths(file, max_lengths_of_data_size)
  data_count = { lines: 0, words: 0, bytes: 0, path: nil }

  file.each_line do |l|
    data_count[:lines] += 1
    word_array = l.split(' ')
    data_count[:words] += word_array.count
  end
  data_count[:bytes] = file.bytesize

  max_lengths_of_data_size[:lines] = calculate_max_length(data_count[:lines], max_lengths_of_data_size[:lines])
  max_lengths_of_data_size[:words] = calculate_max_length(data_count[:words], max_lengths_of_data_size[:words])
  max_lengths_of_data_size[:bytes] = calculate_max_length(data_count[:bytes], max_lengths_of_data_size[:bytes])

  [data_count, max_lengths_of_data_size]
end

def calculate_max_length_of_stdin(params, max_lengths_of_data_size)
  if params.values.count(true) == 1
    0
  elsif max_lengths_of_data_size.values.max < 8
    7
  else
    max_lengths_of_data_size.values.max - 2
  end
end

def calculate_max_length_of_file(params, max_lengths_of_data_size)
  if params.values.count(true) == 1
    0
  else
    max_lengths_of_data_size.values.max
  end
end

def calculate_sum_and_max_length(data_counts)
  data_count_sum = { lines: 0, words: 0, bytes: 0, path: '合計' }
  max_length_of_sum = 0
  data_counts.each do |data_count|
    data_count_sum[:lines] += data_count[:lines]
    data_count_sum[:words] += data_count[:words]
    data_count_sum[:bytes] += data_count[:bytes]

    max_length_of_sum = [max_length_of_sum, [data_count_sum[:lines], data_count_sum[:words], data_count_sum[:bytes]].max.to_s.length].max
  end
  data_counts << data_count_sum

  [data_counts, max_length_of_sum]
end

opt = OptionParser.new

params = {}
opt.on('-l') { |v| params[:l] = v }
opt.on('-w') { |v| params[:w] = v }
opt.on('-c') { |v| params[:c] = v }
opt.parse!(ARGV)

data_counts = []
string_lengths_of_data_size = { lines: 0, words: 0, bytes: 0, path: 0 }

if ARGV.empty?
  data_count, string_lengths_of_data_size = find_file_data_and_max_lengths($stdin.read, string_lengths_of_data_size)
  data_counts << data_count

  string_length = calculate_max_length_of_stdin(params, string_lengths_of_data_size)

else
  ARGV.each do |file_path|
    data_count, string_lengths_of_data_size = find_file_data_and_max_lengths(File.read(file_path), string_lengths_of_data_size)
    data_count[:path] = file_path
    data_counts << data_count
  end

  if ARGV.count == 1
    string_length = calculate_max_length_of_file(params, string_lengths_of_data_size)
  else
    data_counts, string_length_of_sum = calculate_sum_and_max_length(data_counts)
    string_length = [string_lengths_of_data_size.values.max, string_length_of_sum].max
  end
end

data_counts.each do |data_count|
  if params[:l] || params.none?
    print data_count[:lines].to_s.rjust(string_length)
    print ' '
  end
  if params[:w] || params.none?
    print data_count[:words].to_s.rjust(string_length)
    print ' '
  end
  if params[:c] || params.none?
    print data_count[:bytes].to_s.rjust(string_length)
    print ' '
  end
  puts data_count[:path]
end
