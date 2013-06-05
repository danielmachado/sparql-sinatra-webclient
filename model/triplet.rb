#triplet.rb

# @author Daniel Machado Fernández
# @version 1.0
#
# Represents a N3 Triple
class Triplet
	
	# @!attribute x
	# @return [String] subject from a statement
	attr_accessor :x
	
	# @!attribute p
	# @return [String] predicate from a statement
	attr_accessor :p
	
	# @!attribute o
	# @return [String] object from a statement
	attr_accessor :o
	
	# Converts the internal state of the model in a String
	#
	# @return [String] with the model representation
	def to_s
		res = @x + " " + @p + " " + @o
		res
	end

end