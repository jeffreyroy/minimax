require_relative 'minimax'
require_relative 'game'


# FOR SIMPLICITY Moves are restricted to subset of available moves
# Classes
class Gomoku < Game
  attr_reader :current_state
  attr_accessor :minimax

  # Constants

  SYMBOLS = { :human => "X", :computer => "O" }
  DIRECTIONS = [[1, 0], [0, 1], [1, 1], [-1, 1]]

  ## 1. Methods common to all games, can be redefined if necessary

  # Initialize new game
  def initialize
    player = :human
    # Position = 19 * 19 array, each space initialized to dot
    position = Array.new(19) { Array.new(19, ".") }
    # FOR SIMPLICITY Force computer move to center
    position[9][9] = "O"
    # State is a hash consisting of the current position and the
    # Player currently to move
    @current_state = { :position => position, :player => player }
    # FOR SIMPLICITY Restrict moves to spaces adjacent to last moves
    @last_move = { :human => [9, 9], :computer => [9, 9] }
  end

  # Get current position
  def current_position
    @current_state[:position]
  end

  # Get current player
  def current_player
    @current_state[:player]
  end

  # Get opponent of specified player
  def opponent(player)
    player == :human ? :computer : :human
  end

  # Make a move and update the state
  def make_move(move)
    # FOR SIMPLICTY update last move
    player = current_state[:player]
    @last_move[player] = move

    # Update state
    @current_state = next_state(@current_state, move)

  end

  # Choose move for computer
  # using minimax
  # def computer_move
  #   return nil if done?(@current_state)
  #   # Pick best move using minimax algorithm
  #   move = @minimax.best_move(@current_state)
  #   # Make the move
  #   display_computer_move(move)
  #   make_move(move)
  # end

  def computer_move
    get_move
  end

  ## 2. Game-specific methods to make moves

  # Legal moves for minimax algorithm
  # Returns array containing list of legal moves in given state
  def legal_moves(state)
    position = state[:position]
    moves = []
    #  Loop through all spaces on grid
    # position.each_with_index do |row, i|
    #   row.each_with_index do |space, j|
    #     # If space empty, add to result
    #     moves << [i, j] if space == "."
    #   end
    # end

    # FOR SIMPLICITY restrict moves to spaces adjacent to last moves
    @last_move.each_pair do |player, move|
      # Calculate range of space to check
      row = move[0]
      row_min = [row - 1, 0].max
      row_max = [row + 1, 18].min
      column = move[1]
      column_min = [column - 1, 0].max
      column_max = [column + 1, 18].min
      (row_min..row_max).each do |i|
        (column_min..column_max).each do |j|
          if position[i][j] == "." && !moves.index([i, j])
            moves << [i, j]
          end
        end
      end
    end
  moves
  end

  # Given state and move, return resulting state after move is made
  # That means updating the position, and also (usually) switching
  # the player to the opponent
  def next_state(state, move)
    position = state[:position]
    player = state[:player]
    next_position = Array.new(position)
    # Add appropriate symbol to move location
    next_position[move[0]][move[1]] = self.class::SYMBOLS[player]
    # Swap players
    next_player = opponent(player)
    { :position => next_position, :player => next_player}
  end

  # Get the player's move and make it
  def get_move
    # Fill this in.  Sample code:
    puts
    display_position(@current_state)
    move = nil
    until move != nil
      puts
      print "Enter your move (x, y): "
      move_string = gets.chomp
      move_array = move_string.split(",")
      if move_array.length != 2
        puts "You must enter two coordinates."
      else
        move = [move_array[1].to_i, move_array[0].to_i]
      end
      if !legal_moves(@current_state).index(move)
        puts "That's not a legal move!"
        move = nil
      end
    end
    make_move(move)
  end

  ## 3. Game-specific methods to determine outcome

  # Check whether game is over
  def done?(state)
    legal_moves(state).empty?
  end

  def inbounds?(row, column)
    row >= 0 && row <= 18 && column >= 0 && column <= 18
  end

  # Helper method to find winning formations
  # Attempts to find five symbols in a row including specified space
  def find_win(position, row, column, symbol)
    # Make sure starting space includes required symbol
    print position[row][column]
    return false if position[row][column] != symbol
    # Loop over all directions
    self.class::DIRECTIONS.each do |direction|
      return true if five_in_a_row(position, row, column, symbol, direction)
    end
    return false
  end

  def five_in_a_row(position, row, column, symbol, direction)
    row_increment = direction[0]
    column_increment = direction[1]
    total_length = 0
    # From starting space, check forwards and backwards
    [[-1, -1], [1, 1]].each do |multiplier|
      current_row = row
      current_column = column
      # Count number of symbols in a row
      while inbounds?(current_row, current_column) && position[current_row][current_column] == symbol
        total_length += 1
        current_row += multiplier[0] * row_increment
        current_column += multiplier[0] * column_increment
      end
    end
    # Return true if five in a row found
    p total_length
    total_length > 5
  end

  # Check whether game has been won by the player currently on the move
  # in the specified state
  def won?(state)
    # Fill this in
    position = state[:position]
    player = state[:player]
    last_move = @last_move[player]
    row = last_move[0]
    column = last_move[1]
    symbol = self.class::SYMBOLS[player]
    find_win(position, row, column, symbol)
  end

  # Check whether game has been lost by the player currently on the move
  # in the specified state
  def lost?(state)
    # Fill this in
    position = state[:position]
    player = opponent(state[:player])
    last_move = @last_move[player]
    row = last_move[0]
    column = last_move[1]
    symbol = self.class::SYMBOLS[player]
    find_win(position, row, column, symbol)
  end

  ## 4. Game-specific displays

  # Display the current position
  def display_position(state)
    position = state[:position]
    puts "  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8"
    position.each_with_index do |row, i|
      print i % 10
      print " " + row.join(" ") + " "
      puts i % 10
    end
    puts "  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8"

    # FOR SIMPLICITY display last move
    last_player = opponent(state[:player])
    last_move = @last_move[last_player]
    puts
    print "Last move: #{last_player} to "
    p last_move

  end

  # Display the computer's move
  def display_computer_move(move)
    # Fill this in
  end

end

# Driver code


# Driver code
game = Gomoku.new
# minimax = Minimax.new(game)
# game.minimax = minimax

complete = false
while !complete
  game.get_move
  if game.lost?(game.current_state)
    puts "You win!!"
    complete = true
  elsif game.done?(game.current_state)
    puts "Cat's game!"
    complete = true
  else
    game.computer_move
    if game.lost?(game.current_state)
      puts "I win!" 
      complete = true
    end
  end
end

game.display_position(game.current_state)



