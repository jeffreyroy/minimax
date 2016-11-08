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
  # { :position => <current position>, :player => <player to move> }
  def best_move_with_score(state)
    position = state[:position]
    player = state[:player]
    legal_moves = @game.legal_moves(state)
    if legal_moves.empty?
      return[nil, 0]
    end
    best_score = -999
    best_move = nil
    next_player = @game.opponent(player)
    score_array = legal_moves.map do |move|
      # Generate resulting state
      score_state = @game.next_state(state, move)
      # Score resulting position (for opponent)
      move_score = score(score_state)
      # Check whether this move is best so far
      if move_score > best_score
        best_move = move
        best_score = move_score
      end
    end
    # Return best move
    # print best_score

    [best_move, best_score]
  end

  # For testing
  # Show all states with calculated scores
  def show_scores
    puts "Showing scores: "
    @state_scores.each_pair do |state, score|
      position = state[:position]
      player = state[:player]
      puts
      @game.display_position(position)
      puts "Player to move: #{player}"
      puts "Score: #{score}"
    end
  end

  # Returns score of a game state for the player to move
  def score(state)
    position = state[:position]
    # If state has already been scored, return score
    if @state_scores.has_key?(state)
      return @state_scores[state]
    end
    # If @game is over, return appropriate score
    if @game.won?(state)
      best_score = 10  # player won
    elsif @game.lost?(state)
      best_score = -10  # player lost
    elsif @game.done?(state)
      best_score = 0  # draw
    elsif @depth > 100
      # If too deep, treat as draw
      # Probably due to moving back and forth
      best_score = 0
    else
      # Otherwise find and score best move for opponent
      @depth += 1
      best_score = best_move_with_score(state)[1]
      @depth -= 1
    end
    # Add score to master list and return it
    # (Score is negative of opponent's best score)
    @state_scores[state] = -best_score
  end
end