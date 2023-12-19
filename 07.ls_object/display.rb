# frozen_string_literal: true

require_relative './directory'

class Display
  def initialize(input)
    @display_files = Directory.new(input).files
  end

  COLUMN_NUMBER = 3

  def reject_dot_files
    @display_files = @display_files.reject { |file| file.name.start_with?('.') }
    self
  end

  def reverse_files
    @display_files = @display_files.reverse
    self
  end

  def calculate_block_counts
    @display_files.sum(&:blocks) / 2
  end

  def display_simple_list
    row_number = (@display_files.size.to_f / COLUMN_NUMBER).ceil

    max_lengths =
      @display_files.each_slice(row_number).map do |display_files|
        display_files.map { |file| file.name.size }.max
      end

    before_format_display_files = @display_files.map(&:name).each_slice(row_number).to_a
    before_format_display_files.last.size == row_number || before_format_display_files.last.fill(nil, before_format_display_files.last.size...row_number)
    formatted_display_files = before_format_display_files.transpose

    formatted_display_files.each_with_object([]) do |display_files, output|
      display_files.map.with_index do |file, index|
        print file.ljust(max_lengths[index] + 2) unless file.nil?
      end
      puts
    end
  end

  def display_detailed_list
    max_nlink = @display_files.map { |file| file.nlink.to_s.size }.max
    max_user = @display_files.map { |file| file.user.size }.max
    max_group = @display_files.map { |file| file.group.size }.max
    max_size = @display_files.map { |file| file.bytesize.to_s.size }.max

    puts "合計 #{calculate_block_counts}"
    @display_files.map do |file|
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
