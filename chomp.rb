require_relative 'minimax'

# Classes
class Game
  attr_accessor :current_position, :current_player, :minimax

  # Initialize new game of chomp
  # position is a two-dimensional array consisting of ones
  def initialize(position)
    @current_position = position
    @current_player = :human
  end

  # State is a hash consisting of the current position and the
  # Player currently to move
  def current_state
    { :position => @current_position, :player => @current_player }
  end

  def opponent(player)
    return :computer if player == :human
    :human
  end

   # Check whether game is over
  def done?(state)
    state[:position][0][0] == 0
  end

  # Check whether game has been won by a player
  # (Whoever takes the last object wins)
  def lost?(state)
    done?(state)  && !won?(state)
  end

  def won?(state)
    done?(state)
  end

  # Legal moves for minimax algorithm
  # Move expressed as coordinates of cell to be chomped
  def legal_moves(state)
    position = state[:position]
    move_list = []
    # Loop over all cells in the position
    position.each_with_index do |row, row_index|
      row.each_with_index do |value, column_index|
        # If cell value is one, add it to the move list
        if value == 1
          move_list << [row_index, column_index]
        end
      end
    end
    move_list
  end

  # Given position and move, return resulting position
  # Move expressed as coordinates of cell to be chomped
  def next_position(state, move)
    position = state[:position]
    result = position.each_with_index.map do |row, x|
      row.each_with_index.map do |value, y|
        ( x >= move[0] && y >= move[1] ) ? 0 : value
      end
    end
    result
  end

  # Display the current position
  def display_position(position)
    puts "Current position: "
    position.each do |row|
      puts row.join(" ")
    end
  end

  # Get the player's move
  def get_move
    display_position(@current_position)
    return nil if done?(current_state)
    pending = true
    height = @current_position.length
    width = @current_position[0].length
    while pending
      puts
      print "Enter move as row, column: "
      move = gets.chomp.split(",")
      # Check to make sure move is legal
      if move.length != 2
        puts "You need to enter two coordinates."
      else
        row = move[0].to_i
        column = move[1].to_i
        if row < 0 || row > height + 1
          puts "Row must be between 0 and #{height - 1}"
        elsif column < 0 || column > width + 1
          puts "Column must be between 0 and #{width - 1}"
        elsif @current_position[row][column] == 0
          puts "That cell has already been chomped!"
        else
          # It's a legal move
          pending = false
        end
      end
    end
    # Make the move
    @current_position = next_position(current_state, [row, column])
    @current_player = :computer
  end

  # Choose move for computer
  def computer_move
    return nil if done?(current_state)
    state = { :position => @current_position, :player => :computer}
    # Pick best move using minimax algorithm
    move = @minimax.best_move(state)
    p move
    # Make the move
    row = move[0]
    column = move[1]
    puts "I chomp position #{row}, #{column}"
    @current_position = next_position(current_state, move)
    @current_player = :human
  end


end

# Driver code
game = Game.new([[1, 1 ,1], [1, 1 ,1]])
minimax = Minimax.new(game)
game.minimax = minimax

while !game.done?(game.current_state)
  game.get_move
  if game.won?(game.current_state)
    puts "I win!!"
  else
    game.computer_move
    puts "You win!" if game.won?(game.current_state)
  end
end
