require_relative 'piece'

class CheckersPiece < Piece
  attr_reader :value
  attr_accessor :color, :player
  ICON = "OX"
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

  def directions
    # Fill this in
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

  def legal_moves(position)
    # puts "Generating moves for piece at #{@location}..."
    move_list = []
    # Loop over directions
    directions.each do |d|
      destination = [@location[0] + d[0], @location[1] + d[1]]
      if inbounds(destination)
        # If position empty, add to move list
        if empty_space?(position, destination)
          move_list << [@location, destination]
        elsif !same_owner(position, destination)
          # If occupied by opponent, check for capture
          capture_destination = [destination[0] + d[0], destination[1] + d[1]]
          if inbounds(capture_destination) && empty_space?(position, capture_destination)
            move_list << [@location, capture_destination]
          end
        end
      end
    end
    # (En passant capture no yet implemented)
    # Return move list
    move_list
  end

end

class Checker < CheckersPiece
  ICON = "Oo"
  VALUE = 1

  def directions
    direction = (@player == :human ? -1 : 1)
    [[direction, 1], [direction, -1]]
  end

end

class King < CheckersPiece
  ICON = "Kk"
  VALUE = 2

  def directions
    [[1, 1], [1, -1], [-1, 1], [-1, -1]]
  end

end