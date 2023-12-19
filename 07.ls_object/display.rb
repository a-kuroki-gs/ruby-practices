# frozen_string_literal: true

class Display
  def initialize(files)
    @display = files
  end

  COLUMN_NUMBER = 3

  def display_simple_list
    row_number = (@display.size.to_f / COLUMN_NUMBER).ceil

    max_lengths =
      @display.each_slice(row_number).map do |display|
        display.map { |file| file.name.size }.max
      end

    before_format_display = @display.map(&:name).each_slice(row_number).to_a
    before_format_display.last.size == row_number || before_format_display.last.fill(nil, before_format_display.last.size...row_number)
    formatted_display = before_format_display.transpose

    formatted_display.each do |display|
      display.map.with_index do |file, index|
        print file.ljust(max_lengths[index] + 2) unless file.nil?
      end
      puts
    end
  end

  def display_detailed_list(block_counts)
    max_nlink = @display.map { |file| file.nlink.to_s.size }.max
    max_user = @display.map { |file| file.user.size }.max
    max_group = @display.map { |file| file.group.size }.max
    max_size = @display.map { |file| file.bytesize.to_s.size }.max

    puts "合計 #{block_counts}"
    @display.map do |file|
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
