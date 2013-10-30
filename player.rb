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
		# Override in child to get rid of error
		raise NotImplementedError.new("Player#make_guess not implemented!")
	end

	def locations_of_guess(guess)
		# Override in child to get rid of error
		raise NotImplementedError.new("Player#locations_of_guess not implemented!") 
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

		# Add guess to list of guesses made
		@guesses << guess

		guess
	end

	# Return locations of guessed letter in secret word
	def locations_of_guess(guess)
		# Prompt user to confirm a guess
		input = prompt("Is #{guess} in your word?: ", "Invalid input!")

		locations = []
		# If the player says the guessed letter is in the secret word
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

		# Find matching words from reduced dictionary
		@dictionary.words.select! do |word|
			word.length == known_string.length && word =~ regex
		end
		
		freqs = letter_frequency_hash(@dictionary.words)

		# Get array of keys, sorted by value in descending order
		sorted_keys = freqs.sort_by { |letter, count| count }.reverse.map{ |pair| pair[0] }
		
		# Get rid of guesses already made
		best_guesses = sorted_keys - @guesses
		
		# Choose first guess in list and add to guesses made
		guess = best_guesses[0]
		@guesses << guess
		
		guess
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