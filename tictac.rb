require_relative 'minimax'
require_relative 'game'

# Classes
class Tictactoe < Game

  BOARD_TRANS = [0, 6, 1, 8, 7, 5, 3, 2, 9, 4]
  BOARD_REV_TRANS = [0, 2, 7, 6, 9, 5, 1, 4, 3, 8]
  MARKERS = ["   ", " O ", " X "]

  def initialize
    position = [-1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    player = :human
    # State is a hash consisting of the current position and the
    # Player currently to move
    @current_state = { :position => position, :player => player }
  end

  def number(player)
    (player == :human) ? 2 : 1
  end

  # Get marker on square on the board (1-9)
  def marker(num)
    square_code = current_position[self.class::BOARD_TRANS[num]]
    self.class::MARKERS[square_code]
  end

  def print_line(line)
    start = line * 3 - 2
    markers = [0, 1, 2].map { |i| marker(start + i) }
    puts markers.join("|")
  end

  # Print the entire board (only works for current position)
  def display_position
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
    display_position
    array_square = 0
    until array_square > 0
      puts
      print "Enter your move (1-9): "
      player_move = gets.chomp.to_i
      array_square = self.class::BOARD_TRANS[player_move]

      if !legal_moves(@current_state).index(array_square)
        puts "That's not a legal move!"
        array_square = 0
      end
    end
    make_move(array_square)
  end

  # Check whether game is over
  # (ie whether the board is full)
  def done?(state)
    position = state[:position]
    position.index(0) == nil
  end

  # check row using magic square
  # value: 1 = computer, 2 = player
  def check_row(position, a, b, value)
    c = 15 - a - b
    # Squares are out of bounds (should not ever happen)
    if a < 1 || a > 9  || b < 1 || b > 9
      puts "Out of bounds error while checking row #{a} #{b}!"
      return false
    # Third space is not legal
    elsif c < 1 || c > 9 || c == a || c == b || a == b
      return false
    # Check whether third space has the value we're looking
    elsif position[a] == value && position[b] == value && position[c] == value
      return true
    else
      return false
    end
  end

  # Checks all straight lines on board to try to find a formation
  # Line must contain two cells with firstValue and one with secondValue
  # a, b, c are board spaces in magic square notation
  # checkMove returns cell with value if formation is found
  # otherwise returns nil
  def check_move(position, value)
    move = nil
    (1..9).each do |a|
      (1..9).each do |b|
        if check_row(position, a, b, value)
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
    check_move(position, n) ? true : false
  end

  def lost?(state)
    position = state[:position]
    player = opponent(state[:player])
    won?( { :position => position, :player => player } )
  end

  def display_computer_move(move)
    puts "I move #{self.class::BOARD_REV_TRANS[move]}"
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

  # Given position and move, return resulting position
  # Move expressed as number of square 1-9
  def next_state(state, move)
    position = state[:position]
    player = state[:player]
    result = Array.new(position)
    # array_square = self.class::BOARD_TRANS[move]
    result[move] = number(player)
    next_player = opponent(player)
    { :position => result, :player => next_player }
  end

end

# Driver code
game = Tictactoe.new
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

game.display_position





