class Montecarlo

  def initialize(game, max_tries = 100, max_depth = 100)
    @game = game
    # State stats hash keeps track of scor,s and tries for each state
    # { state => { :score => total_score, :tries = total_tries } }
    @state_stats = {}
    @max_tries = max_tries
    @max_depth = max_depth
    @depth = 0
  end

  # Find the best move
  def best_move(state)
    best_score = -999
    best_move = nil
    # Run allowed number of simulations
    (1..@max_tries).each do |try|
      print "\rSimulation #{try}/#{@max_tries}"
      simulate(state)
    end
    # Loop through legal moves
    @game.legal_moves(state).each do |move|
      new_state = @game.next_state(state, move)
      stats = @state_stats[new_state]
      if stats
        new_score = stats[:score] / stats[:tries]
      else
        new_score = -99
      end
      # Check whether current move is best so far
      if new_score > best_score
        best_score = new_score
        best_move = move
      end
    end
    # Return best move
    best_move
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

  # Pick a random move
  def pick_move(state)
    @game.legal_moves(state).sample
  end

  # Recursive tree search simulates a random game
  def simulate(state)
    player = state[:player]
    if @game.won?(state) && player == :computer
      score = 100  # computer won
    elsif @game.lost?(state) && player == :computer
      score = -200  # computer lost
    elsif @game.won?(state) && player == :human
      score = -200  # computer lost
    elsif @game.lost?(state) && player == :human
      score = 100  # computer won
    elsif @game.done?(state)
      score = 0  # draw
    elsif @depth > @max_depth
      score = 1  # beyond allowable depth
    else
      move = pick_move(state)
      # print "\rConsidering "
      # print move
      new_state = @game.next_state(state, move)
      @depth += 1
      score = simulate(new_state)
      @depth -= 1
    end
    update_stats(state, score)
    score
  end

  # For testing
  # Show all states and stats
  def show_scores
    puts "Showing stats: "
    @state_scores.each_pair do |state, stats|
      print "State: "
      p state
      puts "Score: #{stats[0]/stats[1]}"
    end
  end

end 