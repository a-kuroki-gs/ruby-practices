# frozen_string_literal: true

class Game
  def initialize(game_mark)
    game_marks = game_mark.split(',')

    @frames = []
    9.times do
      rolls = game_marks.shift(2)
      if rolls.first == 'X'
        @frames << Frame.new('X', '0')
        game_marks.unshift(rolls.last)
      else
        @frames << Frame.new(rolls.first, rolls.last)
      end
    end
    @frames << Frame.new(game_marks[0], game_marks[1], game_marks[2])
  end

  def bonus_of_strike(next_frame, after_next_frame)
    if next_frame.strike?
      10 + after_next_frame.first_shot.score
    else
      next_frame.score
    end
  end

  def bonus_of_spare(next_frame)
    next_frame.first_shot.score
  end

  def bonus_of_ninth_frame(ninth_frame, last_frame)
    if ninth_frame.strike?
      last_frame.first_shot.score + last_frame.second_shot.score
    elsif ninth_frame.spare?
      last_frame.first_shot.score
    end
  end

  def score
    game_score = @frames.map(&:score).sum

    @frames.each_cons(3) do |current_frame, next_frame, after_next_frame|
      if current_frame.strike?
        game_score += bonus_of_strike(next_frame, after_next_frame)
      elsif current_frame.spare?
        game_score += bonus_of_spare(next_frame)
      end
    end

    game_score += bonus_of_ninth_frame(@frames[-2], @frames[-1]).to_i
  end
end
