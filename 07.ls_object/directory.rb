# frozen_string_literal: true

require_relative './file'

class Directory
  attr_reader :files

  COLUMN_NUMBER = 3

  def initialize(directory)
    @files =
      Dir.entries(directory).sort.each_with_object([]) do |file, files|
        path = "#{directory}/#{file}"
        files << File.new(path)
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

  def print_not_l_option
    # 表示するファイルの数から行数を求める
    row_number = (@files.size.to_f / COLUMN_NUMBER).ceil

    # ３個おきに最大を求める
    max_lengths =
      @files.each_slice(row_number).map do |files|
        files.map { |file| file.name.size }.max
      end

    # 配列を作って転置する
    before_format_files = @files.map(&:name).each_slice(row_number).to_a
    before_format_files.last.size == row_number || before_format_files.last.fill(nil, before_format_files.last.size...row_number)
    formatted_files = before_format_files.transpose

    # １行ずつ表示する
    formatted_files.each_with_object([]) do |files, output|
      output <<
        files.map.with_index do |file, index|
          file.ljust(max_lengths[index] + 2) unless file.nil?
        end.join.rstrip
    end
  end

  def print_l_option
    # 最大を取得
    max_nlink = @files.map { |file| file.nlink.to_s.size }.max
    max_user = @files.map { |file| file.user.size }.max
    max_group = @files.map { |file| file.group.size }.max
    max_size = @files.map { |file| file.bytesize.to_s.size }.max

    # １行ずつ表示
    output =
      @files.map do |file|
        [
          file.mode,
          " #{file.nlink.to_s.rjust(max_nlink)}",
          " #{file.user.ljust(max_user)}",
          " #{file.group.ljust(max_group)}",
          " #{file.bytesize.to_s.rjust(max_size)}",
          " #{file.mtime}",
          " #{file.name}"
        ].join
      end

    output.join("\n")
  end
end
