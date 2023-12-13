# frozen_string_literal: true

require_relative './file'

class Directory
  attr_reader :files

  COLUMN_NUMBER = 3

  def initialize(directory)
    @files =
      Dir.entries(directory).sort.map do |file|
        path = "#{directory}/#{file}"
        File.new(path)
      end
  end

  def reject_dot_files
    @files = @files.reject { |file| file.name.start_with?('.') }
    self
  end

  def reverse_files
    @files = @files.reverse
    self
  end

  def calculate_block_counts
    @files.sum(&:blocks) / 2
  end

  def print_simple_list_format
    row_number = (@files.size.to_f / COLUMN_NUMBER).ceil

    max_lengths =
      @files.each_slice(row_number).map do |files|
        files.map { |file| file.name.size }.max
      end

    before_format_files = @files.map(&:name).each_slice(row_number).to_a
    before_format_files.last.size == row_number || before_format_files.last.fill(nil, before_format_files.last.size...row_number)
    formatted_files = before_format_files.transpose

    formatted_files.each_with_object([]) do |files, output|
      output <<
        files.map.with_index do |file, index|
          file.ljust(max_lengths[index] + 2) unless file.nil?
        end.join
    end
  end

  def print_detailed_list_format
    max_nlink = @files.map { |file| file.nlink.to_s.size }.max
    max_user = @files.map { |file| file.user.size }.max
    max_group = @files.map { |file| file.group.size }.max
    max_size = @files.map { |file| file.bytesize.to_s.size }.max

    @files.map do |file|
      [
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
