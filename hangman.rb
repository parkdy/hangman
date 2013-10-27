require './dictionary'
require './prompt'

class Hangman
	def initialize
		@players = []
		@tries_remaining = 10
	end

	def play
		puts "Welcome to Hangman!"
		@players = get_players

		guesser, checker = @players
		
		secret_length = checker.secret_length
		known_string = "_" * secret_length

		puts "\n#{known_string}   (#{secret_length} letters)\n"

		until @tries_remaining == 0
			puts "You have #{@tries_remaining} tries remaining."
			puts "You already guessed: #{guesser.guesses.join(", ")}"

			guess = guesser.make_guess(known_string)

			locations = checker.locations_of_guess(guess)
			if locations.any? 
				# Correct guess
				puts "You guessed '#{guess}' correctly!"
				# Update display string
				locations.each { |i| known_string[i] = guess }
			else 
				# Incorrect guess
				puts "Sorry, you guessed '#{guess}' incorrectly!"

				@tries_remaining -= 1
			end

			puts "#{known_string}   (#{secret_length} letters)\n\n"

			if game_won?(known_string)
				puts "Congratulations, you guess the word #{known_string}!"
				puts "You won with #{@tries_remaining} tries remaining!"
				return
			end
		end

		puts "Sorry, you lost!"
	end

	def game_won?(known_string)
		!known_string.include?('_')
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

class Player
	attr_accessor :guesses
	
	def initialize
		@guesses = []
		@secret_length = nil
	end

	def secret_length
		@secret_length
	end

	def make_guess
		# TODO
	end

	def locations_of_guess(guess)
		# TODO
	end
end

class HumanPlayer < Player
	def secret_length
		prompt_msg = "Enter length of secret word: "
		error_msg = "Invalid length!\n"
		input = prompt(prompt_msg, error_msg) { |input| input.to_i > 0 }

		@secret_length = input.to_i
	end

	def make_guess(known_string)
		# Prompt user to guess a letter
		prompt_msg = "Guess a letter: "
		error_msg = "Invalid guess! Enter a letter that hasn't been guessed before.\n"
		guess = prompt(prompt_msg, error_msg) do |input|
			input.downcase.between?('a','z') && !@guesses.include?(input.downcase)
		end

		@guesses << guess
		guess
	end

	# Return locations of guessed letter in secret word
	def locations_of_guess(guess)
		# Prompt user to confirm a guess
		input = prompt("Is #{guess} in your word?: ", "Invalid input!")

		locations = []
		# If the guessed letter is in the secret word
		if (input.downcase == 'y' || input.downcase == 'yes' )
			# Prompt for the locations
			prompt_msg = "Enter locations of '#{guess}' in your word separated by spaces: "
			error_msg = "Invalid input! Enter location of #{guess} in your word separated by spaces!\n"
			input = prompt(prompt_msg, error_msg) do |input|
				input.split(' ').all? { |location| location.to_i.between?(0, @secret_length-1) }
			end

			locations = input.split(' ').map(&:to_i)
		end
		locations
	end
end

class ComputerPlayer < Player
	def initialize
		@guesses = []
		@dictionary = Dictionary.new

		# No contractions of multiple words!
		@dictionary.words.select! { |word| Dictionary.only_letters?(word) }

		# Generate random secret word
		@secret_word = @dictionary.words.sample
		@secret_length = @secret_word.length
	end

	def make_guess(known_string)
		regex = matching_regex(known_string)

		@dictionary.words.select! do |word|
			word.length == known_string.length && word =~ regex
		end
		
		freqs = letter_frequency_hash(@dictionary.words)

		# Get array of keys, sorted by value in descending order
		sorted_keys = freqs.sort_by { |letter, count| count }.reverse.map{ |pair| pair[0] }
		best_guesses = sorted_keys - @guesses
		guess = best_guesses[0]
		@guesses << guess
		guess

		# guess = [('a'..'z').to_a - @guesses].sample
		# @guesses << guess
		# guess
	end

	def letter_frequency_hash(words)
		freqs = Hash.new(0)
		words.each do |word|
			word.each_char { |letter| freqs[letter] += 1 }
		end
		freqs
	end

	def locations_of_guess(guess)
		locations = []
		if @secret_word.include?(guess)	
			@secret_word.split('').each_with_index do |letter, location|
				locations << location if letter == guess
			end
		end

		locations
	end

	def matching_regex(known_string)
		regex_str = known_string.split('').map{ |chr| chr == '_' ? '.' : chr }.join('')
		Regexp.new(regex_str)
	end
end

game = Hangman.new
game.play