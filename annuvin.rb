# require_relative 'monte_carlo'
require_relative 'minimax'
require_relative 'game'

class Annuvin < Game
  attr_reader :current_state
  attr_accessor :minimax

  INITIAL_BOARD = ["- - . . .",
                    "- . . . .",
                     ". . . . .",
                      ". . . . -",
                       " . . . - -"]

  ## 1. Methods common to all games, can be redefined if necessary

  # Initialize new game
  def initialize
    player = :human
    position = init_board
    # State is a hash consisting of the current position and the
    # Player currently to move
    @current_state = { :position => position, :player => player }
  end

  # Initialize 3x3 hex board
  def init_board
    board_string = self.class::INITIAL_BOARD
    board = board_string.map do |row|
      row.split(" ")
    end
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
    @current_state = next_state(@current_state, move)
  end

  # Choose move for computer
  # using minimax
  def computer_move
    return nil if done?(@current_state)
    # Pick best move using minimax algorithm
    move = @minimax.best_move(@current_state)
    # Make the move
    display_computer_move(move)
    make_move(move)
  end

  # Use this to calculate score of any position beyond
  # the depth of the search tree
  # Default is just to return 0 (even)
  # This should be customized for any game that is too deep to
  # calculate to the end
  def heuristic_score(state)
    0
  end

  ## 2. Game-specific methods to make moves

  # Legal moves for minimax algorithm
  # Returns array containing list of legal moves in given state
  def legal_moves(state)
    # Fill this in
  end

  # Given state and move, return resulting state after move is made
  # That means updating the position, and also (usually) switching
  # the player to the opponent
  def next_state(state, move)
    # Fill this in.  Sample code:
    # position = state[:position]
    # player = state[:player]
    # < define resulting position as next_position >
    # next_player = opponent(player)
    # { :position => next_position, :player => next_player}
  end

  # Get the player's move and make it
  def get_move
    # Fill this in.  Sample code:
    # puts
    # display_position
    # move = nil
    # until move != nil
    #   puts
    #   print "Enter your move: "
    #   move_string = gets.chomp
    #   < interpret move_string as move >
    #   if !legal_moves(@current_state).index(move)
    #     puts "That's not a legal move!"
    #     move = nil
    #   end
    # end
    # make_move(move)
  end

  ## 3. Game-specific methods to determine outcome

  # Check whether game is over
  def done?(state)
    # Fill this in
  end

  # Check whether game has been won by the player currently on the move
  # in the specified state
  def won?(state)
    # Fill this in
  end

  # Check whether game has been lost by the player currently on the move
  # in the specified state
  def lost?(state)
    # Fill this in
  end

  ## 4. Game-specific displays

  # Display the current position
  def display_position(state)
    position = state[:position]
    count = 0
    position.each do |row|
      print " " * count
      formatted_row = row.map { |space| space == "-" ? " " : space }
      puts formatted_row.join(" ")
      count += 1
    end
    # Fill this in
  end

  # Display the computer's move
  def display_computer_move(move)
    # Fill this in
    # Example code:
    # print "I move: "
    # p move
  end

end

# Driver code
game = Annuvin.new

game.display_position(game.current_state)


