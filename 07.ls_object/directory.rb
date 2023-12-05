# frozen_string_literal: true

require_relative './file'

class Directory
  attr_reader :files

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

  # def print_not_l_option

  # end

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
