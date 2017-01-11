require_relative 'piece'

class ChessPiece < Piece
  attr_reader :value
  attr_accessor :color, :player
  ICON = "  "
  VALUE = 0

  def initialize(game, location, player)
    @game = game
    @location = location
    @value = self.class::VALUE
    @icon = self.class::ICON
    @player = player
  end

  def icon
    @player == :human ? @icon[0] : @icon[1]
  end

  # Return icon of piece at location
  def piece_icon(position, location)
    position[location[0]][location[1]]
  end

  # Return true if location in position is empty
  def empty_space?(position, location)
    piece_icon(position, location) == "."
  end

  # Check whether piece at destination is owned by same player
  # as moving piece
  def same_owner(position, piece, location)
    icon1 = piece.icon 
    icon2 = piece_icon(position, location)
    # Check to see whether both icons have same case
    (icon1 == icon1.upcase) == (icon2 == icon2.upcase)
  end

end

class Rook < ChessPiece
  ICON = "Rr"
  VALUE = 5
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]]


  def legal_moves(position)
    # puts "Generating moves for piece at #{@location}..."
    move_list = []
    # Loop over directions
    self.class::DIRECTIONS.each do |direction|
      row_inc = direction[0]
      col_inc = direction[1]
      row = @location[0] + row_inc
      column = @location[1] + col_inc
      destination = [row, column]
      #  Move along this direction as long as spaces are empty
      while inbounds(destination) && empty_space?(position, destination) 
        move_list << [@location, destination]
        row += row_inc
        column += col_inc
        destination = [row, column]
      end
      # If next space is inbounds (i.e. occupied) add as capture
      if inbounds(destination) && !same_owner(position, self, destination)
        move_list << [@location, destination]
      end
    end
    # Return move list
    move_list
  end
end