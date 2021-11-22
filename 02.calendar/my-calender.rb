#!/usr/bin/env ruby
require "date"
require 'optparse'

default_date = Date.today
option_year = default_date.year
option_month = default_date.month

options = ARGV.getopts("y:m:")

#-y-mそれぞれ引数を取った場合(nilじゃなかった場合)
option_year = options["y"].to_i unless options["y"] == nil
option_month = options["m"].to_i unless options["m"] == nil

start_date = Date.new(option_year, option_month)
last_date = Date.new(option_year, option_month, -1)
week_labels = ["日", "月", "火", "水", "木", "金", "土"]

# 中央揃えにするために半角スペースを6つ頭につけている
puts("      #{start_date.month}月 #{start_date.year}")
puts week_labels.join(" ")

# 初日の曜日を揃えるためにスペースを最初に表示しておく
start_date.wday.times { print("  ", " ") }
start_date.step(last_date) do |date|
  day_string = date.day.to_s
  day_string = day_string.rjust(2)

  if date == default_date
    day_string = "\e[7m#{day_string}\e[0m"
  end

  if date.saturday? || date == last_date
    day_string += "\n"
  else
    day_string += " "
  end
  print day_string
end
puts "\n"
