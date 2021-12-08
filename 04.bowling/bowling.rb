#!/usr/bin/env ruby
# frozen_string_literal: true

scores = ARGV[0].split(',')
frames = 10
delivered_count = 0
score = 0

def calc_score(score)
  if score == 'X'
    10
  else
    score.to_i
  end
end

frames.times do
  # ストライクの場合
  if scores[delivered_count] == 'X'
    score += 10
    score += calc_score(scores[delivered_count + 1])
    score += calc_score(scores[delivered_count + 2])
    delivered_count += 1
  # スペアの場合
  elsif scores[delivered_count].to_i + scores[delivered_count + 1].to_i == 10
    score += scores[delivered_count].to_i
    score += calc_score(scores[delivered_count + 1])
    score += calc_score(scores[delivered_count + 2])
    delivered_count += 2
  else
    score += scores[delivered_count].to_i
    score += calc_score(scores[delivered_count + 1])
    delivered_count += 2
  end
end
puts score
