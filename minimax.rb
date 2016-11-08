class Minimax

  def initialize(game)
    @game = game
    @state_scores = {}
    @depth = 0
  end

  def best_move(state)
    best_move_with_score(state)[0]
  end

  # Recursive minimax algorithm divided into two parts
  # First part picks best move for a player
  # Second part assigns score to move

  # Pick best move for player to move
  # State is the state of the game expressed as a hash
  # { :postition => <current position>, :player => <player to move> }
  def best_move_with_score(state)
    position = state[:position]
    player = state[:player]
    legal_moves = @game.legal_moves(position)
    if legal_moves.empty?
      return[nil, 0]
    end
    best_score = -999
    best_move = nil
    next_player = @game.opponent(player)
    score_array = legal_moves.map do |move|
      # Generate resulting position
      score_position = @game.next_position(position, move)
      score_state = { :position => score_position, :player => next_player }
      # Score resulting position (for opponent)
      move_score = score(score_state)
      # Check whether this move is best so far
      if move_score > best_score
        best_move = move
        best_score = move_score
      end
    end
    # Return best move
    print best_score
    [best_move, best_score]
  end

  # Returns score of a position for the player to move
  # state = state of the game
  # maximizing_player = true / false
  def score(state)
    position = state[:position]
    player = state[:player]
    next_player = @game.opponent(player)
    # If state is in master list, return score
    if @state_scores.has_key?(state)
      return @state_scores[state]
    end
    # If @game is over, return appropriate score
    if @game.won?(state)
      return -10  # player won
    elsif @game.lost?(state)
      return 10  # player lost
    elsif @game.done?(state)
      return 0  # draw
    end
    # Otherwise find and score best move for opponent
    @depth += 1
    best_score = best_move_with_score(state)[1]
    @depth -= 1
    # Add score to master list and return it
    # (Score is negative of opponent's best score)
    @state_scores[state] = -best_score
  end
end