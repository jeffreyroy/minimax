class Montecarlo

  def initialize(game, max_tries = 100, max_depth = 100)
    @game = game
    # State stats hash keeps track of scores and tries for each state
    # { state => { :score => total_score, :tries = total_tries } }
    @state_stats = {}
    @max_tries = max_tries
    @max_depth = max_depth
    @depth = 0
    @c = Math.sqrt(2)  # Exploration constant for UCB
  end

  # Find the best move
  def best_move(state)
    best_score = -999
    best_move = nil
    dot = (@max_tries / 10).floor
    # Run allowed number of simulations
    print "Thinking"
    (1..@max_tries).each_with_index do |try, i|
      print "." if i % dot == 0
      simulate(state)
    end
    show_scores(state)
    pick_move(state)

  end

  # Update stats with simulated score
  def update_stats(state, score)
    if @state_stats.has_key?(state)
      @state_stats[state][:score] += score
      @state_stats[state][:tries] += 1
    else
      @state_stats[state] = { :score => score, :tries => 1}
    end
  end

  # Pick the most promising move
  def pick_move(state)
    legal_moves = @game.legal_moves(state)
    # Check to see whether any moves have not yet been tried
    untried_moves = []
    untried_moves = legal_moves.select { |move|
      !@state_stats.has_key?(@game.next_state(state, move))
      }

    # If all moves tried, pick using upper confidence bound
    if untried_moves.empty?
      return ubt_move(state)
    end
    
    # If moves remain untried, pick one at random
    untried_moves.sample
  end

  # Pick most promising move using upper confidence bound
  # Requires all moves to have been tried at least once
  def ubt_move(state)
    legal_moves = @game.legal_moves(state)
    best_move = nil
    best_bound = -999
    legal_moves.each do |move|
      upper_bound = ucb(state, move)
      if upper_bound > best_bound
        best_bound = upper_bound
        best_move = move
      end
    end
    # print "\r Examining #{best_move}  Depth #{@depth} "
    best_move
  end

  # Calculate upper confidence bound for specific move
  def ucb(state, move)
    total_tries = @state_stats[state][:tries]
    new_state = @game.next_state(state, move)
    stats = @state_stats[new_state]
    score = stats[:score]
    tries = stats[:tries]
    # Calculate upper confidence bound using formula
    (score / tries) + @c * Math.sqrt( Math.log(total_tries) / tries) 
  end

  # Recursive tree search simulates a random game
  def simulate(state)
    if @game.won?(state)
      score = 100  # player won
    elsif @game.lost?(state)
      score = -100  # player lost
    elsif @game.done?(state)
      score = 0  # draw
    elsif @depth > @max_depth
      score = 0  # beyond allowable depth
    else
      move = pick_move(state)
      # print "\rConsidering "
      # print move
      new_state = @game.next_state(state, move)
      @depth += 1
      score = simulate(new_state)
      @depth -= 1
    end
    update_stats(state, -score)
    -score
  end

  # For testing
  # Show UBT of all moves
  def show_scores(state)
    legal_moves = @game.legal_moves(state)
    legal_moves.each do |move|
      upper_bound = ucb(state, move)
      puts "#{move} - #{upper_bound}"
    end
  end



end 