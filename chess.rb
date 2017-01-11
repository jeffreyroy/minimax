require_relative 'minimax'
require_relative 'game'
require_relative 'chess_pieces'

# Classes
class Chess < Game

  ## Constants and initialization

  COLUMNS = "abcdefgh"
  ROWS = "87654321"

  def initialize
    position = Array.new(8) { Array.new(8, ".") }
    player = :human
    pieces = { human: [], computer: [] }
    # State is a hash consisting of the current position and the
    # Player currently to move
    # Initialize empty board
    @current_state = { :position => position, :player => player, :pieces => pieces }
    # Add pieces to empty board
    add_pieces
    # Intialize ai
    initialize_ai(1, 100)
  end

  # Add initial piece setup to board
  def add_pieces
    position = @current_state[:position]
    # position[0] = "rnbqkbnr".split("")
    # position[1] = "pppppppp".split("")
    # position[6] = "PPPPPPPP".split("")
    # position[7] = "RNBQKBNR".split("")
    position[0] = "r......r".split("")
    position[7] = "R......R".split("")
    @current_state[:pieces] = {
      :human => [ Rook.new(self, [7, 0], :human),
                  Rook.new(self, [7, 7], :human) ],
      :computer => [ Rook.new(self, [0, 0], :computer),
                  Rook.new(self, [0, 7], :computer) ]

    }
    @current_state[:position] = position
  end

  def total_value(piece_list)
    # return 0 if piece_list.empty?
    piece_list.reduce(0) { |sum, piece| sum + piece.value }
  end

  # Score position based on value of remaining pieces
  def heuristic_score(state)
    pieces = state[:pieces]
    player = state[:player]
    total_value(pieces[player]) - total_value(pieces[opponent(player)])
  end

  ## Methods to make moves

  def inbounds(destination)
    row = destination[0]
    column = destination[1]
    row >= 0 && row <= 7 && column >= 0 && column <= 7
  end

  # Legal moves for minimax algorithm
  def legal_moves(state)
    position = state[:position]
    player = state[:player]
    piece_list = state[:pieces][player]
    move_list = []
    # Loop over pieces
    piece_list.each do |piece|
      move_list += piece.legal_moves(position)
    end
    move_list
  end

  # Given position and move, return resulting position
  def next_state(state, move)
    position = Marshal.load(Marshal.dump(state[:position]))
    player = state[:player]
    opp = opponent(player)
    pieces = Marshal.load(Marshal.dump(state[:pieces]))
    from = move[0]
    to = move[1]
    moving_piece = pieces[player].find { |piece| piece.location == from }
    if !moving_piece
      puts "ERROR--no piece to move!"
    end
    # Check for capture
    if position[to[0]][to[1]] != "."
      # Remove enemy piece
      pieces[opp].delete_if { |piece| piece.location == to }
    end
    # Move piece
    position[from[0]][from[1]] = "."
    position[to[0]][to[1]] = moving_piece.icon
    moving_piece.location = to
    # Switch active player
    next_player = opp
    { :position => position, :player => next_player, :pieces => pieces }
  end

  # Interpret algebraic notatin as coordinates
  def coordinates(string)
    return nil if string.length != 2
    # interpret letter as column
    column = self.class::COLUMNS.index(string[0])
    row = self.class::ROWS.index(string[1])
    return nil if !column || !row
    [row, column]
  end

 # Get the player's move and make it
  def get_move
    # Fill this in.  Sample code:
    puts
    display_position
    position = @current_state[:position]
    piece_list = @current_state[:pieces][:human]
    move = nil
    piece = nil
    while piece == nil
      # puts "Legal moves: "
      # p legal_moves(@current_state)
      puts
      print "Enter location of piece to move: "
      from_label = gets.chomp
      from = coordinates(from_label)
      if from
        if position[from[0]][from[1]] == "."
          puts "That space is empty. "
        else
          puts "I read that as #{from}."
        end
      else
        puts "I don't understand that as a location."
        puts "Please enter a location as a followed by"
        puts "a column, e.g. 'e2'"
      end
      piece = @current_state[:pieces][:human].find { |p| p.location == from }
    end
    puts
    puts "Moving #{piece.icon} at #{from_label}."
    to = [-1, -1]
    while to == [-1, -1]
      print "Enter destination: "
      to = coordinates(gets.chomp)
      if !piece.legal_moves(current_position).include?([from, to])
        puts "That's not a legal destination."
        to = [-1, -1]
      end
    end
    move = [from, to]
    make_move(move)
  end

  ## Methods to determine outcome

  # Check whether game is over
  # (ie whether the board is full)
  def done?(state)
    legal_moves(state).empty?
  end

  # Check whether game has been won by player to move
  def won?(state)
    pieces = state[:pieces]
    player = opponent(state[:player])
    pieces[player].empty?
  end

  # Check whether game has been lost by player to move
  def lost?(state)
    pieces = state[:pieces]
    player = state[:player]
    pieces[player].empty?

  end

  ## Displays

  # Print the entire board (only works for current position)
  def display_position
    current_position.each do |row|
      puts row.join(" ")
    end
  end

  def display_computer_move(move)
    puts "I move #{move}"
  end

end

# Driver code
game = Chess.new

complete = false
while !complete
  game.get_move
  if game.lost?(game.current_state)
    puts "You win!!"
    complete = true
  elsif game.done?(game.current_state)
    puts "Draw!"
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





