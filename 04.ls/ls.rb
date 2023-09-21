#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'etc'
require 'optparse'

FILE_TYPES = {
  '1' => 'p',
  '2' => 'c',
  '4' => 'd',
  '6' => 'b',
  '10' => '-',
  '12' => 'l',
  '14' => 's'
}.freeze

PERMISSIONS = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def print_block_count(input, display_all)
  total_blocks = 0
  Dir.foreach(input) do |i|
    next if !display_all && i.start_with?('.')

    total_blocks += File.lstat("#{input}/#{i}").blocks
  end
  puts "合計 #{total_blocks / 2}"
end

def get_filetype(filetype)
  FILE_TYPES[filetype]
end

def get_name_from_id(id)
  Etc.getpwuid(id).name
end

def get_contents(file_path, max_length)
  e = File.lstat(file_path)
  file = e.mode.to_s(8)
  content_info = {
    filetype: get_filetype(file[..-5]),
    permission: file[-3..],
    hardlink_count: e.nlink.to_s,
    username: get_name_from_id(e.uid),
    groupname: get_name_from_id(e.gid),
    filesize: e.size.to_s,
    updatetime: e.mtime,
    filename: File.basename(file_path)
  }
  max_length[:hardlink_count] = [max_length[:hardlink_count], content_info[:hardlink_count].to_s.length].max
  max_length[:username] = [max_length[:username], content_info[:username].length].max
  max_length[:groupname] = [max_length[:groupname], content_info[:groupname].length].max
  max_length[:filesize] = [max_length[:filesize], content_info[:filesize].to_s.length].max
  max_length[:updatemonth] = [max_length[:updatemonth], content_info[:updatetime].strftime('%-m').length].max

  [content_info, max_length]
end

def print_permission(filemode)
  filemode.each_char do |f|
    print PERMISSIONS[f]
  end
end

def print_updatetime(time, max_length)
  print time.strftime('%-m月').rjust(max_length + 4)
  print time.strftime('%-d').rjust(3)
  print time.strftime('%H:%M').rjust(6)
end

def print_contents(content, max_length)
  print content[:filetype]
  print_permission(content[:permission])
  print ' '
  print content[:hardlink_count].rjust(max_length[:hardlink_count])
  print ' '
  print content[:username].ljust(max_length[:username])
  print ' '
  print content[:groupname].ljust(max_length[:groupname])
  print ' '
  print content[:filesize].rjust(max_length[:filesize])
  print ' '
  print_updatetime(content[:updatetime], max_length[:updatemonth])
  print ' '
  puts content[:filename]
end

def build_filename_array(element, max_length_array)
  max_row_length = element.size.ceildiv(3)
  modified_elements = []
  element.each_slice(max_row_length) do |e|
    max_length_array << e.map(&:length).max
    modified_element = e + [nil] * (max_row_length - e.size)
    modified_elements << modified_element
  end
  modified_elements.transpose
end

def print_filename_array(array, max_width_array)
  array.each do |elements|
    elements.each_with_index do |element, idx|
      element = element.ljust(max_width_array[idx] + 2) unless element.nil?
      print element
    end
    puts
  end
end

def print_filenames(array)
  return if array == []

  max_length_array = []
  filename_array = build_filename_array(array, max_length_array)
  print_filename_array(filename_array, max_length_array)
end

def reject_hidden_files(filename)
  filename.reject { |f| f.start_with?('.') }
end

opt = OptionParser.new

params = {}
opt.on('-a') { |v| params[:a] = v }
opt.on('-r') { |v| params[:r] = v }
opt.on('-l') { |v| params[:l] = v }
opt.parse!(ARGV)

input_all =
  if ARGV == []
    ['.']
  else
    params[:r] ? ARGV.sort.reverse : ARGV.sort
  end

target_dir_all = []
target_file_all = []
dir_on_input = false
file_on_input = false
input_all.each do |input|
  if File.ftype(input) == 'directory'
    target_dir_all << input
    dir_on_input = true
  else
    target_file_all << input
    file_on_input = true
  end
end

if file_on_input
  if params[:l]
    max_length = { hardlink_count: 0, username: 0, groupname: 0, filesize: 0, updatemonth: 1 }
    target_file_all.each do |target_file|
      content_info, max_length = get_contents(target_file, max_length)
      print_contents(content_info, max_length)
    end
  else
    print_filenames(target_file_all)
  end
end

if dir_on_input
  puts if file_on_input

  target_dir_all.each_with_index do |target_dir, idx|
    puts if idx != 0
    puts "#{target_dir}:" if input_all.size > 1

    if params[:l]
      print_block_count(target_dir, params[:a])
      content_info_array = []
      max_length = { hardlink_count: 0, username: 0, groupname: 0, filesize: 0, updatemonth: 1 }
      Dir.entries(target_dir).sort.each do |target|
        next if !params[:a] && target.start_with?('.')

        target_path = "#{target_dir}/#{target}"
        content_info, max_length = get_contents(target_path, max_length)
        content_info_array << content_info
      end
      content_info_array = content_info_array.reverse if params[:r]
      content_info_array.each do |c|
        print_contents(c, max_length)
      end
    else
      target_dir = Dir.entries(target_dir).sort
      target_dir = reject_hidden_files(target_dir) if !params[:a]
      target_dir = target_dir.reverse if params[:r]

      print_filenames(target_dir)
    end
  end
end
