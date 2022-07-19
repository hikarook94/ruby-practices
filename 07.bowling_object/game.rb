# frozen_string_literal: true

require_relative 'frame'

class Game
  attr_reader :frames

  def initialize(marks)
    pins = parse_marks(marks)
    @frames = generate_frames(pins)
  end

  def score
    @frames.sum(&:total_score)
  end

  private

  def parse_marks(marks)
    marks.split(',').map { |m| m == 'X' ? 10 : m.to_i }
  end

  def generate_frames(pins)
    frames = []
    9.times do
      rolls = pins.shift(2)
      if rolls.first == 10
        frame = Frame.new(rolls.first)
        frames << frame
        pins.unshift(rolls.last)
        frame.bonus = pins[0, 2]
      else
        frame = Frame.new(*rolls)
        frame.bonus = pins[0, 1] if frame.spare?
        frames << frame
      end
    end
    frames << Frame.new(*pins)
  end
end
