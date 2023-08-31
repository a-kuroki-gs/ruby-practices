#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OptionParser.new

input_all = ARGV

input_all << '.' if input_all == []

target_dir_all = []
input_dir_all = []
dir_on_input = false
file_on_input = false

input_all.each do |input|
  if File.ftype(input) == 'directory'
    target_dir_all << Dir.entries(input)
    input_dir_all << input
    dir_on_input = true
  else
    print input.ljust(input.size + 2)
    file_on_input = true
  end
end

if file_on_input
  puts
  puts if dir_on_input
end

colon_dir_all = []
normal_dir_all = []
target_dir_all.each do |target_dir|
  colon_dir = []
  normal_dir = []
  target_dir.each do |target|
    if target[0] == '.'
      colon_dir << target
    else
      normal_dir << target
    end
  end
  # TODO: colon_dir_allは-aオプションの表示で利用する
  colon_dir_all << colon_dir
  normal_dir_all << normal_dir
end

normal_dir_all = normal_dir_all.map(&:sort)

def build_element_array(element, max_name_size_array)
  max_row_length = element.size.ceildiv(3)

  modified_elements = []
  element.each_slice(max_row_length) do |e|
    max_name_size_array << e.map(&:length).max
    modified_element = e + [nil] * (max_row_length - e.size)
    modified_elements << modified_element
  end

  modified_elements.transpose
end

def print_element_array(dir, max_width_array)
  dir.each do |elements|
    elements.each_with_index do |element, idx|
      element = element.ljust(max_width_array[idx] + 2) unless element.nil?
      print element
    end
    puts
  end
end

def print_elements(element)
  max_name_size_array = []

  element = build_element_array(element, max_name_size_array)

  print_element_array(element, max_name_size_array)
end

normal_dir_all.each_with_index do |normal, idx|
  if normal_dir_all.size > 1 || file_on_input
    puts if idx != 0
    puts "#{input_dir_all[idx]}:"
  end
  print_elements(normal)
end
