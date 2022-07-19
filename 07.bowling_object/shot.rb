# frozen_string_literal: true

class Shot
  attr_reader :score

  def initialize(mark = nil)
    @score = mark.to_i
  end
end
