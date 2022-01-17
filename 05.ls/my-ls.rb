#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

COLUMN_NUM = 3
COLUMN_SPACE = 3
# 以下の分類はstat(2)のマニュアルを参照した
FILE_TYPE_HASH_TABLE = {
  '14' => 's', # Socket link
  '12' => 'l', # Symbolic link
  '10' => '-', # Regular file
  '06' => 'b', # Block special file
  '04' => 'd', # Directory
  '02' => 'c', # Character special file
  '01' => 'p' # FIFO
}.freeze

def parse_option
  opt = OptionParser.new
  params = {}
  opt.on('-a') { |flag| params[:a] = flag }
  opt.on('-r') { |flag| params[:r] = flag }
  opt.on('-l') { |flag| params[:l] = flag }
  opt.parse(ARGV)
  params
end

def get_filenames(options_hash)
  glob_option = options_hash.key?(:a) ? File::FNM_DOTMATCH : 0
  filename_array = Dir.glob('*', glob_option)
  options_hash.key?(:r) ? filename_array.reverse : filename_array
end

def generate_with_l_option(filenames)
  display_array = []
  total = 0
  file_object_array = filenames.map { |filename| File.new(filename) }
  file_object_array.each_with_index do |file_object, index|
    file_object_stat = file_object.stat
    total += file_object.lstat.blocks if File.fnmatch('*', file_object, File::FNM_DOTMATCH)

    file_array = []
    file_array << decode_modes(file_object.lstat.mode).join
    file_array << file_object_stat.nlink.to_s.rjust(3)
    file_array << Etc.getpwuid(file_object_stat.uid).name
    file_array << Etc.getgrgid(file_object_stat.gid).name
    file_array << file_object.lstat.size.to_s.rjust(5)
    file_array << trim_mtime(file_object_stat.mtime)
    file_array << filenames[index]
    file_array << trim_symlink(filenames[index]) if File.symlink?(filenames[index])

    display_array << file_array
  end
  display_array.unshift ["total #{total}"]
  show(display_array)
end

def decode_modes(modes)
  six_digit_mode = format('%06o', modes)
  modes_array = []

  file_type_bits = six_digit_mode.slice!(0, 2)
  modes_array << FILE_TYPE_HASH_TABLE[file_type_bits]

  special_bits = format('%03b', six_digit_mode.slice!(0))
  permissions_bits_array = six_digit_mode.chars.map { |char| format('%03b', char) }

  permissions_bits_array.each_with_index do |bits, index|
    modes_array << get_permissions(bits, index, special_bits)
  end
  modes_array
end

def get_permissions(bits, index, special_bits)
  rwx_array = %w[r w x]
  bits.chars.each_with_index do |bit, bit_index|
    rwx_array[bit_index] = '-' if bit == '0'
  end
  rwx_array[-1] = overwrite_x(bits[-1], index) if special_bits[index] == '1'
  rwx_array.join
end

def overwrite_x(last_bit, index)
  case last_bit
  when '1'
    index < 2 ? 's' : 't'
  else
    index < 2 ? 's'.upcase : 't'.upcase
  end
end

def trim_mtime(mtime)
  month = mtime.month.to_s.rjust(2)
  day = mtime.day.to_s.rjust(2)
  year = mtime.year.to_s.rjust(5)
  six_month_before = Time.now.to_date.prev_month(6).to_time

  third_place = mtime.strftime('%R')
  third_place = year if mtime < six_month_before || Time.now < mtime
  "#{month} #{day} #{third_place}"
end

def trim_symlink(file_name)
  "-> #{File.readlink(file_name)}"
end

def add_spaces(files_array)
  max_filename_length = files_array.map(&:length).max

  files_array.map do |file|
    file.ljust(max_filename_length + COLUMN_SPACE)
  end
end

def generate(spaced_files_array)
  row_num = spaced_files_array.size.fdiv(COLUMN_NUM).ceil
  display_array = Array.new(row_num).map { [] }

  spaced_files_array.each_with_index do |file, index|
    display_array[index % row_num] << file
  end
  show(display_array)
end

def show(display_array)
  display_array.each do |array|
    puts array.join(' ')
  end
end

options_hash = parse_option
files_array = get_filenames(options_hash)
if options_hash.key?(:l)
  generate_with_l_option(files_array)
else
  spaced_files_array = add_spaces(files_array)
  generate(spaced_files_array)
end
