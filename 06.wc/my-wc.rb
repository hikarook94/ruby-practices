#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
opt = OptionParser.new
params = {}
opt.on('-l') { |v| params[:l] = v }
opt.parse!(ARGV)

def get_lines_from_file(arg)
  arg.map do |path|
    IO.readlines(path)
  end
end

def generate_file_stats(lines, words, bytesize, params)
  array = []
  array << lines.size.to_s.rjust(8)
  array << words.to_s.rjust(7) unless params.key?(:l)
  array << bytesize.to_s.rjust(7) unless params.key?(:l)
  array
end

def generate(lines_array, params, paths = [])
  file_stats_array = []
  total_lines_count = 0
  total_words_count = 0
  total_byte_size = 0
  lines_array.each_with_index do |lines, index|
    words_count = 0
    bytesize = 0
    lines.each do |line|
      words_count += line.scan(/\S+/).size
      bytesize += line.bytesize
    end
    file_stats = generate_file_stats(lines, words_count, bytesize, params)
    file_stats << paths[index] unless paths.empty?
    file_stats_array << file_stats
    total_lines_count += lines.size
    total_words_count += words_count
    total_byte_size += bytesize
  end
  file_stats_array << [total_lines_count.to_s.rjust(8), total_words_count.to_s.rjust(7), total_byte_size.to_s.rjust(7), 'total'] if paths.size >= 2
  file_stats_array.each { |n| puts n.join(' ') }
end

lines_array = ARGV.empty? ? [readlines] : get_lines_from_file(ARGV)
generate(lines_array, params, ARGV)
