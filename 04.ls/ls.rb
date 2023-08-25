#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

OptionParser.new

# 標準入力を受け取って変数に代入
input_all = ARGV

# 引数がなければカレントディレクトリを指定
input_all << '.' if input_all == []

target_dir_all = []
input_dir_all = []
dir_on_input = false
file_on_input = false

# 入力された引数がディレクトリなら探索対象のディレクトリを探索、ファイルなら表示
input_all.each do |input|
  if File.ftype(input) == 'directory'
    target_dir_all << Dir.entries(input)
    input_dir_all << input
    dir_on_input = true
  else
    print input.ljust(input.size + 2)
    file_on_input = true
  end
end

# ファイルを表示して改行、ディレクトリがあれば空行を挿入
if file_on_input == true
  puts
  puts if dir_on_input == true
end

colon_dir_all = []
normal_dir_all = []
# .から始まるものとそれ以外で分ける
target_dir_all.each do |target_dir|
  colon_dir = []
  normal_dir = []
  target_dir.each do |target|
    if target[0] == '.'
      colon_dir << target
    else
      normal_dir << target
    end
  end
  colon_dir_all << colon_dir
  normal_dir_all << normal_dir
end

# .から始まらないものを昇順に並べる
normal_dir_all = normal_dir_all.map(&:sort)

# 表示する列数に応じて行数を計算するメソッド
def calc_num_of_lines(element_count, col)
  # ファイル数をcolで割って余りが0ならelement_count行
  if (element_count % col).zero?
    element_count / col
  # ファイル数をcolで割って余りが0でなければelement_count + 1 行
  else
    element_count / col + 1
  end
end

# 最大ファイル文字数+2の幅で、配列の要素を表示するメソッド
def print_element(dir, max_width_array)
  dir.each do |elements|
    elements.each_with_index do |element, idx|
      element = element.ljust(max_width_array[idx] + 2) unless element.nil?
      print element
    end
    puts
  end
end

# 要素を表示するメソッド
def print_elements(element)
  # ３列表示の時の行数を計算
  max_row_length = calc_num_of_lines(element.size, 3)

  modified_elements = []
  max_name_size_array = []

  # 行として分割
  element.each_slice(max_row_length) do |e|
    # 行(のちの列)ごとに最大ファイル文字数をカウント
    max_name_size_array << e.map(&:length).max
    # 要素が足りないところにはnilを代入
    modified_element = e + [nil] * (max_row_length - e.size)
    modified_elements << modified_element
  end
  element = modified_elements

  # 要素を転置
  element = element.transpose

  # 最大ファイル文字数+2の幅で、nil以外の配列の要素を表示
  print_element(element, max_name_size_array)
end

# lsコマンドと同じように表示
normal_dir_all.each_with_index do |normal, idx|
  if normal_dir_all.size > 1 || file_on_input == true
    puts if idx != 0
    puts "#{input_dir_all[idx]}:"
  end
  print_elements(normal)
end
