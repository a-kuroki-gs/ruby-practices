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
input = ARGV[0] || '.'

directory = Directory.new(input)

directory = directory.reject_dot_files unless params[:a]
directory = directory.reverse_files if params[:r]

if params[:l]
  puts "合計 #{directory.calculate_block_counts}"
  puts directory.print_l_option
else
  puts directory.print_not_l_option
end
