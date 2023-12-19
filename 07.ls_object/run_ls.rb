# frozen_string_literal: true

require 'optparse'

require_relative './display'

opt = OptionParser.new

params = { l: false, r: false, a: false }
opt.on('-l') { |v| params[:l] = v }
opt.on('-r') { |v| params[:r] = v }
opt.on('-a') { |v| params[:a] = v }
opt.parse!(ARGV)
input = ARGV[0] || '.'

display_files = Display.new(input)

display_files = display_files.reject_dot_files unless params[:a]
display_files = display_files.reverse_files if params[:r]

if params[:l]
  display_files.display_detailed_list
else
  display_files.display_simple_list
end
