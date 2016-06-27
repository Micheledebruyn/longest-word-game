require 'open-uri'

class WordsController < ApplicationController
  def game
    @grid = generate_grid(9)
    @start_time = Time.now.to_i
  end

  def score
    @grid = params[:grid].upcase.split("")
    @attempt = params[:attempt]
    @start_time = Time.at(params[:start_time].to_i)
    @end_time = Time.now

    @result = run_game(@attempt, @grid, @start_time, @end_time)

  end

  def generate_grid(grid_size) # creates a random grid in the form of an array
    array_grid = []
    array_alphabet = ('A'..'Z').to_a

    (1..grid_size).each do ||
      random_letter = array_alphabet.sample
      array_grid << random_letter
    end

    return array_grid
  end

  def fetch_translation(attempt)
  api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"
  open(api_url) do |stream|
    translation = JSON.parse(stream.read)

    if translation['term0'].nil?
      return nil
    else
      return translation['term0']['PrincipalTranslations']["0"]['FirstTranslation']['term']
    end
  end
end


def in_the_grid?(attempt, grid)
  answer_array = attempt.upcase.split("")
  answer_array.each do |letter|
    return false if answer_array.count(letter) > grid.count(letter)
  end
  return true
end

def run_game(attempt, grid, start_time, end_time)
  result_hash = { score: 0 }

  if !in_the_grid?(attempt, grid)
    result_hash[:message] = "not in the grid"
  elsif result_hash[:translation] = fetch_translation(attempt)
    result_hash[:score] = (attempt.size * 10) - (end_time - start_time)
    result_hash[:message] = "well done"
  else
    result_hash[:message] = "not an english word"
  end
  return result_hash
end

end
