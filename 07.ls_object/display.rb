# frozen_string_literal: true

class Display
  COLUMN_NUMBER = 3

  def initialize(files)
    @file_stats = files
  end

  def print_simple_list
    row_number = (@file_stats.size.to_f / COLUMN_NUMBER).ceil

    max_lengths = @file_stats.each_slice(row_number).map do |file_stat|
      file_stat.map { |file| file.name.size }.max
    end

    before_format_display = @file_stats.map(&:name).each_slice(row_number).to_a
    before_format_display.last.size == row_number || before_format_display.last.fill(nil, before_format_display.last.size...row_number)
    formatted_display = before_format_display.transpose

    formatted_display.each do |display|
      display.each_with_index do |file, index|
        print file.ljust(max_lengths[index] + 2) unless file.nil?
      end
      puts
    end
  end

  def print_detailed_list(block_counts)
    max_nlink = @file_stats.map { |file| file.nlink.to_s.size }.max
    max_user = @file_stats.map { |file| file.user.size }.max
    max_group = @file_stats.map { |file| file.group.size }.max
    max_size = @file_stats.map { |file| file.bytesize.to_s.size }.max

    puts "合計 #{block_counts}"
    @file_stats.each do |file|
      puts [
        file.mode,
        " #{file.nlink.to_s.rjust(max_nlink)}",
        " #{file.user.ljust(max_user)}",
        " #{file.group.ljust(max_group)}",
        " #{file.bytesize.to_s.rjust(max_size)}",
        " #{file.mtime.strftime('%-m月').rjust(5)}",
        " #{file.mtime.strftime('%e %H:%M')}",
        " #{file.name}"
      ].join
    end
  end
end
