class Piece
  attr_accessor :location, :value

  VALUE = 0

  # Set initial location
  def initialize(game, location)
    @game = game
    @location = location
    @value = self.class::VALUE
  end

  # Return true if location is a valid destination
  # Default is to let game handle this
  def inbounds(destination)
    @game.inbounds(destination)
  end

  # Return list of legal moves
  def legal_moves(position)
    # Fill this in
  end

end