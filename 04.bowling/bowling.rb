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

frames.times do |frame|
  case frame
  # 最終フレーム目
  when 9
    # 最終フレームの時点で残っている投球数の数だけループを回してscoreに加算していく
    (scores.size - delivered_count).times do |t|
      score += calc_score(scores.reverse[t])
    end
  # 1~9フレーム目
  else
    # ストライクの場合
    if scores[delivered_count] == 'X'
      score += 10
      score += calc_score(scores[delivered_count + 1])
      score += calc_score(scores[delivered_count + 2])
      delivered_count += 1
    else
      score += scores[delivered_count].to_i
      score += calc_score(scores[delivered_count + 1])
      frame_total_point = scores[delivered_count].to_i + scores[delivered_count + 1].to_i
      # スペアの場合
      score += calc_score(scores[delivered_count + 2]) if frame_total_point == 10
      delivered_count += 2
    end
  end
end
puts score
