require './dictionary'
require './prompt'
require './player'



class Hangman
	def initialize
		@players = []
		@tries_remaining = 10
	end


	def play
		puts "Welcome to Hangman!"

		# Get human/computer players from input
		@players = get_players

		# Assign guesser and checker
		guesser, checker = @players
		
		# Get length from player who made secret word (checker)
		secret_length = checker.secret_length

		# Known string is initially all unknown
		known_string = "_" * secret_length
		puts "\n#{known_string}   (#{known_string.length} letters)\n"

		until @tries_remaining == 0
			# Make a guess and check it
			play_round(known_string)

			if game_won?(known_string)
				puts "Congratulations, you guess the word #{known_string}!"
				puts "You won with #{@tries_remaining} tries remaining!"
				return
			end
		end

		puts "Sorry, you lost!"
	end


	def get_players
		# Prompt for number of human players
		prompt_msg = "Enter number of human players (0-2): "
		error_msg = "Invalid number of human players (0-2)!\n"
		input = prompt(prompt_msg, error_msg) { |input| input.between?('0','2') }
		num_humans = input.to_i

		# Create appropriate number of humans and computers
		players = []
		num_humans.times { players << HumanPlayer.new }
		(2-num_humans).times { players << ComputerPlayer.new }

		players
	end


	def play_round(known_string)
		# Get guesser and checker
		guesser, checker = @players

		puts "You have #{@tries_remaining} tries remaining."
		puts "You already guessed: #{guesser.guesses.join(", ")}"

		# The guessing player will make a guess
		guess = guesser.make_guess(known_string)

		# Find locations of guessed letter in secret word
		locations = checker.locations_of_guess(guess)
		if locations.any? 
			# Update display string
			locations.each { |i| known_string[i] = guess }

			puts "You guessed '#{guess}' correctly!"				
		else 
			@tries_remaining -= 1

			puts "Sorry, you guessed '#{guess}' incorrectly!"
		end

		puts "#{known_string}   (#{known_string.length} letters)\n\n"
	end


	def game_won?(known_string)
		!known_string.include?('_')
	end
end



game = Hangman.new
game.play