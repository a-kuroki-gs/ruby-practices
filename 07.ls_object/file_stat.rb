# frozen_string_literal: true

require 'etc'

class FileStat
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

  def initialize(path)
    @path = path
    @lstat = File.lstat(@path)
  end

  def mode
    type + permission
  end

  def nlink
    @lstat.nlink
  end

  def user
    Etc.getpwuid(@lstat.uid).name
  end

  def group
    Etc.getpwuid(@lstat.gid).name
  end

  def bytesize
    @lstat.size
  end

  def mtime
    @lstat.mtime
  end

  def name
    File.basename(@path)
  end

  def blocks
    @lstat.blocks
  end

  private

  def type
    FILE_TYPES[@lstat.mode.to_s(8)[..-5]]
  end

  def permission
    @lstat.mode.to_s(8)[-3..].each_char.map { |number| PERMISSIONS[number] }.join
  end
end
