class Dictionary
	DEFAULT_FILE = 'dictionary.txt'

	attr_accessor :words
	

	def initialize(file = DEFAULT_FILE)
		@words = File.readlines(file).map(&:chomp)
	end


	def self.only_letters?(word)
		return (word =~ (/\A[a-zA-Z]+\z/)) ? true : false
	end


	def self.one_letter_off?(word1, word2)
		if word1.length != word2.length
			false
		else
			letters_off = 0
			word1.split('').each_index do |i|
				letters_off += 1 if word1[i] != word2[i]
			end
			letters_off == 1
		end
	end
end