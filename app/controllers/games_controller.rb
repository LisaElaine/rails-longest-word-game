require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    @start_time = Time.now
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    @end_time = Time.now
    @start_time = Time.parse(params[:start_time])
    run_game(params[:guess].upcase, @start_time, @end_time, params[:letters])
  end

  private

  def run_game(guess, start_time, end_time, letters)
    @results = { word: guess, time: end_time - start_time, board: letters }
    english_word(guess)
    @results[:valid] = included?(guess, letters)
    calculate_score(@results[:time], @results[:word])
  end

  def included?(guess, board)
    guess.chars.all? { |letter| guess.count(letter) <= board.count(letter) }
  end

  def english_word(guess)
    response = open("https://wagon-dictionary.herokuapp.com/#{guess}")
    json = JSON.parse(response.read)
    @results[:found] = json['found']
  end

  def calculate_score(time, guess)
    score = time > 60.0 ? 0 : guess.size * (1.0 - time / 60.0).round(0)
    @results[:score] = score
    session[:score] = session[:score].nil? ? session[:score] = score : session[:score] += score
  end
end
