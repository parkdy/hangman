require './dictionary'
require './prompt'

class Hangman
	def initialize
		@dictionary = Dictionary.new
		@players = []
	end

	def play
		@players = get_players
	end

	def get_players
		# Prompt for number of human players
		prompt_msg = "Enter number of human players (0-2): "
		error_msg = "Invalid number of human players (0-2)!\n"
		input = prompt(prompt_msg, error_msg) { |input| input.between?('0','2') }
		num_humans = input.to_i

		# Add appropriate number of humans and computers
		players = []
		num_humans.times { players << HumanPlayer.new }
		(2-num_humans).times { players << ComputerPlayer.new }

		players
	end
end

class HumanPlayer
	def initialize
		@guesses = []
	end

	def make_guess
		# Prompt user to guess a letter
		prompt_msg = "Guess a letter: "
		error_msg = "Invalid guess!\n"
		guess = prompt(prompt_msg, error_msg) do |input|
			input.downcase.between?('a','z') && !@guesses.include?(input)
		end

		# Add guess to list of guesses
		@guesses << guess
		guess
	end

	def confirm_guess(guess)
		# Prompt user to confirm a guess
		input = prompt("Is #{guess} in your word?: ", "Invalid input!")

		return true if (input.downcase == 'y' || input.downcase == 'yes' )
		false
	end
end

class ComputerPlayer
end