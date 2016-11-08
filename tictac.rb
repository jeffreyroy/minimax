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

  def number(player)
    (player == :human) ? 2 : 1
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
    array_square = 0
    until array_square > 0
      puts
      print "Enter your move (1-9): "
      player_move = gets.chomp.to_i
      array_square = self.class::BOARD_TRANS[player_move]

      if !legal_moves(current_state).index(array_square)
        puts "That's not a legal move!"
        array_square = 0
      end
    end
    @current_position = next_position(current_state, array_square)
    @num_moves += 1
    @current_player = :computer
  end

  # Check whether game is over
  def done?(state)
    position = state[:position]
    position.index(0) == nil
  end

  # Values to check for are in va, vb, vc
  # 0 = blank, 1 = computer, 2 = player
  def check_row(position, a, b, va, vb, vc)
    c = 15 - a - b
    # Squares are out of bounds (should not ever happen)
    if a < 1 || a > 9  || b < 1 || b > 9
      puts "Out of bounds error while checking row #{a} #{b}!"
      return false
    # Third space is not legal
    elsif c < 1 || c > 9 || c == a || c == b || a == b
      return false
    # Check whether third space has the value we're looking
    elsif position[a] == va && position[b] == vb && position[c] == vc
      return true
    else
      return false
    end
  end

  # Checks all straight lines on board to try to find a formation
  # Line must contain two cells with firstValue and one with secondValue
  # a, b, c are board spaces in magic square notation
  # checkMove returns cell with secondValue if formation is found
  # otherwise returns nil
  def check_move(position, first_value, second_value)
    move = nil
    (1..9).each do |a|
      (1..9).each do |b|
        if check_row(position, a, b, first_value, first_value, second_value)
          move = 15 - a - b
        end
      end
    end
    move
  end

  # Check whether game has been won by a player
  def won?(state)
    position = state[:position]
    player = state[:player]
    n = number(player)
    check_move(position, n, n) ? true : false
  end

  def lost?(state)
    position = state[:position]
    player = opponent(state[:player])
    won?( { :position => position, :player => player } )
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
  def legal_moves(state)
    position = state[:position]
    move_list = []
    position.each_with_index do |square, index|
      if square == 0
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
    # array_square = self.class::BOARD_TRANS[move]
    result[move] = number(player)
    result
  end

end

# Driver code
game = Game.new
minimax = Minimax.new(game)
game.minimax = minimax
puts game.done?(game.current_state)
puts game.done?( { :position => [-1, 1, 2, 1, 2, 1, 2, 1, 2, 1], :player => :human})

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

game.display_position(game.current_position)





