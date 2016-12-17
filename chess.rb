require_relative 'minimax'
require_relative 'game'

# Classes
class Chess < Game

  ## Constants and initialization

  COLUMNS = "abcdefgh"
  ROWS = "87654321"

  def initialize
    position = Array.new(8) { Array.new(8, ".") }
    player = :human
    pieces = { human: [], computer: [] }
    # State is a hash consisting of the current position and the
    # Player currently to move
    # Initialize empty board
    @current_state = { :position => position, :player => player, :pieces => pieces }
    # Add pieces to empty board
    add_pieces
    # Intialize ai
    initialize_ai(1, 100)
  end

  # Add initial piece setup to board
  def add_pieces
    position = @current_state[:position]
    position[0] = "rnbqkbnr".split("")
    position[1] = "pppppppp".split("")
    position[6] = "PPPPPPPP".split("")
    position[7] = "RNBQKBNR".split("")
    @current_state[:position] = position
  end

  ## Methods to make moves

  def inbounds(destination)
    row = destination[0]
    column = destination[1]
    row >= 0 && row <= 7 && column >= 0 && column <= 7
  end

  # Legal moves for minimax algorithm
  def legal_moves(state)
    position = state[:position]
    player = state[:player]
    piece_list = state[:pieces][player]
    move_list = []
    # Loop over pieces
    piece_list.each do |piece|
      move_list += piece.legal_moves(position)
    end
    move_list
  end

  # Given position and move, return resulting position
  # Move expressed as number of square 1-9
  def next_state(state, move)
    position = state[:position]
    player = state[:player]
    pieces = state[:pieces]

    result[move] = number(player)
    next_player = opponent(player)
    { :position => result, :player => next_player, :pieces => piece_list }
  end

  # Interpret algebraic notatin as coordinates
  def coordinates(string)
    return nil if string.length != 2
    # interpret letter as column
    column = self.class::COLUMNS.index(string[0])
    row = self.class::ROWS.index(string[1])
    return nil if !column || !row
    [row, column]
  end

 # Get the player's move and make it
  def get_move
    # Fill this in.  Sample code:
    puts
    display_position
    position = @current_state[:position]
    piece_list = @current_state[:pieces][:human]
    move = nil
    piece = nil
    while piece == nil
      print "Your pieces: "
      p piece_list
      puts
      print "Enter location of piece to move: "
      from = coordinates(gets.chomp)
      if from
        if position[from[0]][from[1]] == "."
          puts "That space is empty. "
        else
          puts "I read that as #{from}."
        end
      else
        puts "I don't understand that as a location."
        puts "Please enter a location as a followed by"
        puts "a column, e.g. 'e2'"
      end
    end
    puts
    puts "Moving piece at #{from}."
    # moves_left = total_moves(@current_state)
    # capture_only = @current_state[:moving_piece] != nil
    # puts "Valid move locations: "
    # p get_moves(@current_state, piece, moves_left, capture_only)

    # while move == nil
    #   print "Enter location to move: "
    #   destination_string = gets.chomp
    #   destination = destination_string.split(",").map { |x| x.to_i }
    #   move = [piece, destination]
    #   if destination.length != 2
    #     puts "You must enter two coordinates. "
    #     move = nil
    #   elsif !legal_moves(@current_state).index(move)
    #     puts "That's not a legal move!"
    #     move = nil
    #   end
    # end
    # make_move(move)
  end

  ## Methods to determine outcome

  # Check whether game is over
  # (ie whether the board is full)
  def done?(state)
    position = state[:position]
    position.index(0) == nil
  end

  # Check whether game has been won by a player
  def won?(state)
    position = state[:position]
    player = state[:player]

  end

  def lost?(state)
    position = state[:position]
    player = opponent(state[:player])

  end

  ## Displays

  # Print the entire board (only works for current position)
  def display_position
    current_position.each do |row|
      puts row.join(" ")
    end
  end

  def display_computer_move(move)
    puts "I move #{move}"
  end

end

# Driver code
game = Chess.new

complete = false
while !complete
  game.get_move
  if game.lost?(game.current_state)
    puts "You win!!"
    complete = true
  elsif game.done?(game.current_state)
    puts "Draw!"
    complete = true
  else
    game.computer_move
    if game.lost?(game.current_state)
      puts "I win!" 
      complete = true
    end
  end
end

game.display_position





