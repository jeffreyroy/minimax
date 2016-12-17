require_relative 'piece'

class ChessPiece < Piece
  attr_accessor :value, :color
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


end

class Rook < ChessPiece
  ICON = "Rr"
  VALUE = 5
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]]

  def empty_space?(destination)
    position[destination[0]][destination[1]] == "."
  end

  def legal_moves(position)
    move_list = []
    # Loop over directions
    self.class::DIRECTIONS.each do |direction|
      row_inc = direction[0]
      col_inc = direction[1]
      row = @location[0] + row_inc
      column = @location[1] + col_inc
      destination = [row, column]
      #  Move along this direction as long as spaces are empty
      while empty_space?(destination) && inbounds(destination)
        move_list << destination
      end
    end
    # Return move list
    move_list
  end
end