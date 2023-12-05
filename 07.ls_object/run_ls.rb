# frozen_string_literal: true

require 'optparse'

require_relative './file'
require_relative './directory'

opt = OptionParser.new

params = { l: false, r: false, a: false }
opt.on('-l') { |v| params[:l] = v }
opt.on('-r') { |v| params[:r] = v }
opt.on('-a') { |v| params[:a] = v }
opt.parse!(ARGV)
directory = ARGV[0] || '.'

d = Directory.new(directory)

d = d.reject_dot_files unless params[:a]
d = d.reverse_files if params[:r]

if params[:l]
  puts "合計 #{d.calculate_block_counts}"
  puts d.print_l_option
else
  puts d.print_not_l_option
end
