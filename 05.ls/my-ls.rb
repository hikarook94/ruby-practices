#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMN_NUM = 3
COLUMN_SPACE = 4

def parse_option
  opt = OptionParser.new
  params = {}
  opt.on('-a') { |flag| params[:a] = flag }
  opt.on('-r') { |flag| params[:r] = flag }
  opt.parse(ARGV)
  params
end

def get_filenames(options_hash)
  glob_option = options_hash.key?(:a) ? File::FNM_DOTMATCH : 0
  filename_array = Dir.glob('*', glob_option)
  options_hash.key?(:r) ? filename_array.reverse : filename_array
end

def add_spaces(files_array)
  max_filename_length = files_array.map(&:length).max

  files_array.map do |file|
    file.ljust(max_filename_length + COLUMN_SPACE)
  end
end

def generate(spaced_files_array)
  row_num = spaced_files_array.size.fdiv(COLUMN_NUM).ceil

  # 二次元配列はmapメソッドを使っても作成できるがとりあえず残置
  display_array = []
  row_num.times do
    display_array << []
  end

  spaced_files_array.each_with_index do |file, index|
    display_array[index % row_num] << file
  end

  display_array.each do |array|
    puts array.join
  end
end

options_hash = parse_option
files_array = get_filenames(options_hash)
spaced_files_array = add_spaces(files_array)
generate(spaced_files_array)
