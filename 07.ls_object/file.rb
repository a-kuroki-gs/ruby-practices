# frozen_string_literal: true

require 'etc'

class File
  def initialize(path)
    @path = path
    @file = File.lstat(@path)
    @file_mode = @file.mode.to_s(8)
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

  def type
    FILE_TYPES[@file_mode[..-5]]
  end

  def permission
    @file_mode[-3..].each_char.map { |number| PERMISSIONS[number] }.join
  end

  def mode
    type + permission
  end

  def nlink
    @file.nlink
  end

  def user
    Etc.getpwuid(@file.uid).name
  end

  def group
    Etc.getpwuid(@file.gid).name
  end

  def bytesize
    @file.size
  end

  def mtime
    @file.mtime.strftime('%-m').rjust(2) + @file.mtime.strftime('月 %e %H:%M')
  end

  def name
    File.basename(@path)
  end

  def blocks
    @file.blocks
  end
end
