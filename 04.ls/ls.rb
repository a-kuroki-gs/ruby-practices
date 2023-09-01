#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

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

opt = OptionParser.new

params = {}
opt.on('-a') { |v| params[:a] = v }
opt.parse!(ARGV)
input_all =
  if ARGV == []
    ['.']
  else
    ARGV
  end

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

if params[:a]
  dir_all = target_dir_all.map(&:sort)
else
  normal_dir_all = []
  target_dir_all.each do |target_dir|
    normal_dir = []
    target_dir.each do |target|
      normal_dir << target unless target[0] == '.'
    end
    normal_dir_all << normal_dir
  end
  dir_all = normal_dir_all.map(&:sort)
end

dir_all.each_with_index do |dir, idx|
  if dir_all.size > 1 || file_on_input
    puts if idx != 0
    puts "#{input_dir_all[idx]}:"
  end
  print_elements(dir)
end
