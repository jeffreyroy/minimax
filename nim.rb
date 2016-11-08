require_relative 'minimax'
require_relative 'game'

# Classes
class Nim < Game

  # Display the current position
  def display_position(state)
    position = state[:position]

    print "Current position: "
    position.each do |heap|
      print heap
      print " "
    end
    puts
  end

  # Get the player's move
  def get_move
    return nil if done?(@current_state)
    heap = 0
    number = 0
    l = current_position.length
    display_position(@current_state)
    # Pick a heap
    while heap < 1 || heap > l || current_position[heap - 1] == 0
      puts
      puts "Enter heap (1-#{l}): "
      heap = gets.chomp.to_i
      puts "That heap is empty!" if current_position[heap - 1] == 0
    end
    heap -= 1
    max = current_position[heap]
    # Pick number to remove
    while number < 1 || number > max
      puts
      puts "Enter number to remove (1-#{max}): "
      number = gets.chomp.to_i
    end
    move = { :heap => heap, :number => number}
    @current_state = next_state(@current_state, move)

  end

  # Total number of units left in all heaps
  def total_left(state)
    state[:position].reduce(:+)
  end

  # Check whether game is over
  def done?(state)
    total_left(state) == 0
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
    return nil if done?(@current_state)
    state = { :position => current_position, :player => :computer}
    # Pick best move using minimax algorithm
    move = @minimax.best_move(state)
    # Make the move
    heap = move[:heap]
    number = move[:number]
    puts "I remove #{number} from heap #{heap + 1}"
    @current_state = next_state(@current_state, [row, column])
  end

  # Legal moves for minimax algorithm
  def legal_moves(state)
    move_list = []
    position = state[:position]
    position.each_with_index do |heap, index|
      if heap > 0
        (1..heap).each do |number|
          move_hash = { :heap => index, :number => number }
          move_list << move_hash
        end
      end
    end
    move_list
  end

  # Current state
  # State is a hash containing a position and player to move
  def current_state
    { :position => @current_position, :player => @current_player }
  end

  # Given position and move, return resulting position
  def next_state(state, move)
    position = state[:position]
    player = state[:player]
    result = Array.new(position)
    result[move[:heap]] -= move[:number]
    next_player = opponent(player)
    { :position => result, :player => next_player }
  end

end

# Driver code
game = Nim.new([3, 5, 7])
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



