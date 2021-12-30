#!/usr/bin/env ruby
# frozen_string_literal: true

# ファイルの配列を受け取る
files_array = Dir.glob('*')

COLUMN_NUM = 3
COLUMN_SPACE = 4
ROW_NUM = files_array.size.fdiv(COLUMN_NUM).ceil

def add_spaces(files_array)
  # 取得したファイル名の最大の文字数を取得する
  max_filename_length = files_array.map(&:length).max

  # 最大文字数+スペースを右側に空ける
  files_array.map do |file|
    file.ljust(max_filename_length + COLUMN_SPACE)
  end
end

def generate(spaced_files_array)
  # 表示用の配列を作成
  display_array = []

  # 行数分配列を作成して、表示配列に格納
  ROW_NUM.times do
    display_array << []
  end

  # 行数で順番の数字を割った時の剰余をファイル名を配列のインデックスに割り振る
  spaced_files_array.each_with_index do |file, index|
    display_array[index % ROW_NUM] << file
  end

  # 要素の配列を1行ごとに繋げてputsで表示する
  display_array.each do |array|
    puts array.join
  end
end

spaced_files_array = add_spaces(files_array)
generate(spaced_files_array)
