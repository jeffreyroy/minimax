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
  def same_owner(position, location)
    icon1 = self.icon 
    icon2 = piece_icon(position, location)
    # Check to see whether both icons have same case
    (icon1 == icon1.upcase) == (icon2 == icon2.upcase)
  end

  def legal_destination(position, destination)
    inbounds(destination) && (empty_space?(position, destination) || !same_owner(position, destination))
  end

end



class StraightMover < ChessPiece
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
      if inbounds(destination) && !same_owner(position, destination)
        move_list << [@location, destination]
      end
    end
    # Return move list
    move_list
  end
end



class Rook < StraightMover
  ICON = "Rr"
  VALUE = 5
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1]]
end

class Bishop < StraightMover
  ICON = "Bb"
  VALUE = 3
  DIRECTIONS = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
end

class Queen < StraightMover
  ICON = "Qq"
  VALUE = 9
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
end

class King < ChessPiece
  ICON = "Kk"
  VALUE = 50
  DIRECTIONS = [[-1, 0], [1, 0], [0, -1], [0, 1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
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
      # If destination empty or occupied by opponent, add as move
      if legal_destination(position, destination)
        move_list << [@location, destination]
      end
    end
    # Castling not yet implemented
    # Return move list
    move_list
  end
end

class Knight < ChessPiece
  ICON = "Nn"
  VALUE = 3
  DIRECTIONS = [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, -1], [-2, 1]]
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
      # If destination empty or occupied by opponent, add as move
      if legal_destination(position, destination)
        move_list << [@location, destination]
      end
    end
    # Return move list
    move_list
  end
end


class Pawn < ChessPiece
  ICON = "Pp"
  VALUE = 1

  def direction
    @player == :human ? -1 : 1
  end

  def start_row
    @player == :human ? 6 : 1
  end

  def legal_moves(position)
    # puts "Generating moves for piece at #{@location}..."
    move_list = []
    # Add forward move
    # (Promotion not yet implemented)
    destination = [@location[0] + direction, @location[1]]
    if inbounds(destination) && empty_space?(position, destination)
      move_list << [@location, destination]
    end
    # if on starting square, add move two spaces forward
    destination = [@location[0] + 2 * direction, @location[1]]
    intermediate = [@location[0] + direction, @location[1]]
    if @location[0] == start_row && empty_space?(position, destination) && empty_space?(position, intermediate)
      move_list << [@location, destination]
    end
    # Add captures
    capture_directions = [[direction, 1], [direction, -1]]
    # Loop over directions for capture
    capture_directions.each do |d|
      destination = [@location[0] + d[0], @location[1] + d[1]]
      # If position occupied by opponent, add to move list
      if inbounds(destination) && !empty_space?(position, destination) && !same_owner(position, destination)
        move_list << [@location, destination]
      end
    end
    # (En passant capture no yet implemented)
    # Return move list
    move_list
  end
end