# frozen_string_literal: true

require 'etc'

class FileStat
  def initialize(path)
    @path = path
    @file_stat = File.lstat(@path)
  end

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

  def mode
    type + permission
  end

  def nlink
    @file_stat.nlink
  end

  def user
    Etc.getpwuid(@file_stat.uid).name
  end

  def group
    Etc.getpwuid(@file_stat.gid).name
  end

  def bytesize
    @file_stat.size
  end

  def mtime
    @file_stat.mtime
  end

  def name
    File.basename(@path)
  end

  def blocks
    @file_stat.blocks
  end

  private

  def type
    FILE_TYPES[@file_stat.mode.to_s(8)[..-5]]
  end

  def permission
    @file_stat.mode.to_s(8)[-3..].each_char.map { |number| PERMISSIONS[number] }.join
  end
end
