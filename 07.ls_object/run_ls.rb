# frozen_string_literal: true

require 'optparse'

require_relative './display'
require_relative './file_stat'
require_relative './file_manager'

opt = OptionParser.new

params = { l: false, r: false, a: false }
opt.on('-l') { |v| params[:l] = v }
opt.on('-r') { |v| params[:r] = v }
opt.on('-a') { |v| params[:a] = v }
opt.parse!(ARGV)
directory_name = ARGV[0] || '.'

files =
  Dir.entries(directory_name).sort.map do |file|
    path = "#{directory_name}/#{file}"
    FileStat.new(path)
  end

file_manager = FileManager.new(files)

file_manager = file_manager.reject_dot_files unless params[:a]
file_manager = file_manager.reverse_files if params[:r]

display = Display.new(file_manager.files)

if params[:l]
  block_counts = file_manager.calculate_block_counts
  display.display_detailed_list(block_counts)
else
  display.display_simple_list
end
