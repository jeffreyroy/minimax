# Classes
class Game
  attr_reader :current_state
  attr_accessor :minimax

  # Initialize new game
  def initialize(position)
    player = :human
    # State is a hash consisting of the current position and the
    # Player currently to move
    @current_state = { :position => position, :player => player }
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
    return :computer if player == :human
    :human
  end

  # Make a move
  def make_move(move)
    @current_state = next_state(@current_state, move)
  end

   # Check whether game is over
  def done?(state)
    # Fill this in
  end

  # Check whether game has been won the player currently on the move
  # in the specified state
  def won?(state)
    # Fill this in
  end

  def lost?(state)
    # Fill this in
  end

  # Legal moves for minimax algorithm
  # Returns array containing list of legal moves in given state
  def legal_moves(state)
    # Fill this in
  end

  # Given state and move, return resulting state after move is made
  # That means updating the position, and also (usually) switching
  # the player to the opponent
  def next_state(state, move)
    # Fill this in
  end

  # Display the current position
  def display_position(state)
    # Fill this in
  end

  # Get the player's move
  def get_move
    # Fill this in
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

  def display_computer_move(move)
    # Fill this in
  end

end
