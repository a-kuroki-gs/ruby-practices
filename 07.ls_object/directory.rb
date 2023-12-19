# frozen_string_literal: true

require_relative './file'

class Directory
  attr_reader :files

  def initialize(directory)
    @files =
      Dir.entries(directory).sort.map do |file|
        path = "#{directory}/#{file}"
        FileStat.new(path)
      end
  end
end
