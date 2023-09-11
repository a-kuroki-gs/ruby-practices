#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'etc'
require 'optparse'

def print_block_count(input)
  total_blocks = 0
  Dir.foreach(input) do |i|
    next if i.start_with?('.')

    total_blocks += File.lstat("#{input}/#{i}").blocks
  end
  puts "合計 #{total_blocks / 2}"
end

def get_filetype(filetype)
  filetypes = {
    '1' => 'p',
    '2' => 'c',
    '4' => 'd',
    '6' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }
  filetypes[filetype]
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
    case f
    when '0'
      print '---'
    when '1'
      print '--x'
    when '2'
      print '-w-'
    when '3'
      print '-wx'
    when '4'
      print 'r--'
    when '5'
      print 'r-x'
    when '6'
      print 'rw-'
    when '7'
      print 'rwx'
    end
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

opt = OptionParser.new

params = {}
opt.on('-l') { |v| params[:l] = v }
opt.parse!(ARGV)

input_all =
  if ARGV == []
    ['.']
  else
    ARGV.sort
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

if params[:l]
  if file_on_input
    max_length = { hardlink_count: 0, username: 0, groupname: 0, filesize: 0, updatemonth: 1 }
    target_file_all.each do |target_file|
      content_info, max_length = get_contents(target_file, max_length)
      print_contents(content_info, max_length)
    end
  end

  if dir_on_input
    puts if file_on_input

    target_dir_all.each_with_index do |target_dir, idx|
      content_info_array = []
      max_length = { hardlink_count: 0, username: 0, groupname: 0, filesize: 0, updatemonth: 1 }
      puts if idx != 0
      puts "#{target_dir}:" if input_all.size > 1
      print_block_count(target_dir)

      Dir.entries(target_dir).sort.each do |target|
        next if target.start_with?('.')

        target_path = "#{target_dir}/#{target}"
        content_info, max_length = get_contents(target_path, max_length)
        content_info_array << content_info
      end
      content_info_array.each do |c|
        print_contents(c, max_length)
      end
    end
  end
end
