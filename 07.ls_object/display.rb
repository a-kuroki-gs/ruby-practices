# frozen_string_literal: true

class Display
  COLUMN_NUMBER = 3

  def initialize(file_stats, params)
    @file_stats = file_stats
    @params = params
  end

  def print_simple_list
    row_number = (@file_stats.size.to_f / COLUMN_NUMBER).ceil

    max_lengths = @file_stats.each_slice(row_number).map do |file_stat|
      file_stat.map { |file| file.name.size }.max
    end

    before_format_display = @file_stats.map(&:name).each_slice(row_number).to_a
    unless before_format_display.last.size == row_number
      before_format_display.last.fill(nil, before_format_display.last.size...row_number)
    end
    formatted_display = before_format_display.transpose

    formatted_display.each do |display|
      display.each_with_index do |file, index|
        print file.ljust(max_lengths[index] + 2) unless file.nil?
      end
      puts
    end
  end

  def print_detailed_list
    max_nlink = @file_stats.map { |file_stat| file_stat.nlink.to_s.size }.max
    max_user = @file_stats.map { |file_stat| file_stat.user.size }.max
    max_group = @file_stats.map { |file_stat| file_stat.group.size }.max
    max_size = @file_stats.map { |file_stat| file_stat.bytesize.to_s.size }.max

    puts "合計 #{@file_stats.sum(&:blocks) / 2}"
    @file_stats.each do |file_stat|
      puts [
        file_stat.mode,
        file_stat.nlink.to_s.rjust(max_nlink),
        file_stat.user.ljust(max_user),
        file_stat.group.ljust(max_group),
        file_stat.bytesize.to_s.rjust(max_size),
        format('%<month>3s%<day_and_time>9s', month: file_stat.mtime.strftime('%-m月'), day_and_time: file_stat.mtime.strftime('%e %H:%M')),
        file_stat.name
      ].join(' ')
    end
  end

  def print_list
    @file_stats = @file_stats.reject { |file_stat| file_stat.name.start_with?('.') } unless @params[:a]
    @file_stats = @file_stats.reverse if @params[:r]

    if @params[:l]
      print_detailed_list
    else
      print_simple_list
    end
  end
end
