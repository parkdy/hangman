# Repeatedly prompts user for valid input (tested in the passed block) and returns the input
def prompt(prompt_message, error_message, &is_valid)
	input = nil
	invalid = true
	is_valid = Proc.new { |input| true } unless block_given?

	while invalid
		print prompt_message
		input = gets.chomp

		invalid = !is_valid.call(input)
		print error_message if invalid
	end

	input
end