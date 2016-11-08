require_relative 'minimax'

# Classes
class Game
  attr_accessor :current_position, :current_player, :minimax
  BOARD_TRANS = [0, 6, 1, 8, 7, 5, 3, 2, 9, 4]
  BOARD_REV_TRANS = [0, 2, 7, 6, 9, 5, 1, 4, 3, 8]
  MARKERS = ["   ", " O ", " X "]

  def initialize
    @current_position = [-1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    @current_player = :human
    @num_moves = 0
  end

  # State is a hash consisting of the current position and the
  # Player currently to move
  def current_state
    { :position => @current_position, :player => @current_player }
  end

  # Get marker on square on the board (1-9)
  def marker(num)
    square_code = @current_position[self.class::BOARD_TRANS[num]]
    self.class::MARKERS[square_code]
  end

  def print_line(line)
    start = line * 3 - 2
    markers = [0, 1, 2].map { |i| marker(start + i) }
    puts markers.join("|")
  end

  # Print the entire board (only works for current position)
  def display_position(position)
    print_line(1)
    puts "---+---+---"
    print_line(2)
    puts "---+---+---"
    print_line(3)
    puts
  end

  # Get the player's move
  def get_move
    puts
    display_position(@current_position)
    player_move = 0
    until @board.inbounds?(player_move)
      puts
      print "Enter your move (1-9): "
      player_move = gets.chomp.to_i
      if !@board.inbounds?(player_move)
        puts "That's not a legal move!"
      elsif @board.occupied?(player_move)
        puts "That space is already taken."
        player_move = 0
      end
    end
    @current_position = next_position(current_state, player_move)
    @num_moves += 1
    @current_player = :computer
  end

  # Check whether game is over
  def done?(state)
    @num_moves >= 9
  end

  # Check whether game has been won by a player
  # (Whoever takes the last object wins)
  def lost?(state)
    done?(state)
  end

  def won?(state)
    done?(state) && !lost?(state)
  end

   # Choose move for computer
  def computer_move
    return nil if done?(current_state)
    state = { :position => @current_position, :player => :computer}
    # Pick best move using minimax algorithm
    move = @minimax.best_move(state)
    # Make the move
    puts "I move #{move}"
    @current_position = next_position(current_state, move)
    @num_moves += 1
    @current_player = :human
  end

  # Legal moves for minimax algorithm
  def legal_moves(position)
    move_list = []
    position.each_with_index do |square, index|
      if square = 0
        move_list << index
      end
    end
    move_list
  end

  # Current state
  # State is a hash containing a position and player to move
  def current_state
    { :position => @current_position, :player => @current_player }
  end

  def opponent(player)
    return :computer if player == :human
    :human
  end

  # Given position and move, return resulting position
  # Move expressed as number of square 1-9
  def next_position(state, move)
    position = state[:position]
    player = state[:player]
    result = Array.new(position)
    move_number = (player == :human) ? 2 : 1
    result[move] = move_number
    result
  end

end

# Driver code
game = Game.new([3, 5, 7])
minimax = Minimax.new(game)
game.minimax = minimax

while !game.done?(game.current_state)
  game.get_move
  if game.lost?(game.current_state)
    puts "You win!!"
  else
    game.computer_move
    puts "I win!" if game.lost?(game.current_state)
  end
end



