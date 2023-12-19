# frozen_string_literal: true

require 'optparse'

require_relative './display'

opt = OptionParser.new

params = { l: false, r: false, a: false }
opt.on('-l') { |v| params[:l] = v }
opt.on('-r') { |v| params[:r] = v }
opt.on('-a') { |v| params[:a] = v }
opt.parse!(ARGV)
directory_name = ARGV[0] || '.'

display = Display.new(directory_name)

display = display.reject_dot_files unless params[:a]
display = display.reverse_files if params[:r]

if params[:l]
  display.display_detailed_list
else
  display.display_simple_list
end
