# frozen_string_literal: true

require 'optparse'

require_relative './display'
require_relative './file_stat'

opt = OptionParser.new

params = { l: false, r: false, a: false }
opt.on('-l') { |v| params[:l] = v }
opt.on('-r') { |v| params[:r] = v }
opt.on('-a') { |v| params[:a] = v }
opt.parse!(ARGV)
directory_name = ARGV[0] || '.'

file_stats = Dir.entries(directory_name).sort.map do |file|
  path = "#{directory_name}/#{file}"
  FileStat.new(path)
end

display = Display.new(file_stats, params)
display.print_list
