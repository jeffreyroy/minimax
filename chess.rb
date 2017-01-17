require_relative 'minimax'
require_relative 'game'
require_relative 'chess_pieces'
require 'pry'

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
    @current_state = {
      :position => position,
      :player => player,
      :pieces => pieces,
      :force_analysis => false
    }
    # Add pieces to empty board
    add_pieces
    # Intialize ai
    initialize_ai(0, 100)
    @max_force_depth = 3
  end

  # Add initial piece setup to board
  def add_pieces
    # position = @current_state[:position]
    # position[0] = "rnbqkbnr".split("")
    # position[1] = "pppppppp".split("")
    # position[6] = "PPPPPPPP".split("")
    # position[7] = "RNBQKBNR".split("")
    # Add major pieces
    @current_state[:pieces] = {
      :human => [ Rook.new(self, [7, 0], :human),
                  Rook.new(self, [7, 7], :human),
                  Bishop.new(self, [7, 2], :human),
                  Bishop.new(self, [7, 5], :human),
                  Knight.new(self, [7, 1], :human),
                  Knight.new(self, [7, 6], :human),
                  King.new(self, [7, 4], :human),
                  Queen.new(self, [7, 3], :human)
                   ],
      :computer => [ Rook.new(self, [0, 0], :computer),
                  Rook.new(self, [0, 7], :computer),
                  Bishop.new(self, [0, 2], :computer),
                  Bishop.new(self, [0, 5], :computer),
                  Knight.new(self, [0, 1], :computer),
                  Knight.new(self, [0, 6], :computer),
                  King.new(self, [0, 4], :computer),
                  Queen.new(self, [0, 3], :computer)
                ]

    }
    # Add pawns
    (0..7).each do |column|
      @current_state[:pieces][:human] << Pawn.new(self, [6, column], :human)
      @current_state[:pieces][:computer] << Pawn.new(self, [1, column], :computer)
    end
    add_icons
  end

  # Add piece icons to board
  def add_icons
    [:human, :computer].each do |player|
      @current_state[:pieces][player].each do |piece|
        row = piece.location[0]
        column = piece.location[1]
        @current_state[:position][row][column] = piece.icon
      end
    end
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

  def force_analysis(state)
    state[:force_analysis] && @depth < @max_force_depth
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
      move_list += piece.legal_moves(state)
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
    force_analysis = false
    moving_piece = pieces[player].find { |piece| piece.location == from }
    if !moving_piece
      puts "ERROR--no piece to move!"
    end
    # Check for capture
    if position[to[0]][to[1]] != "."
      # Remove enemy piece
      pieces[opp].delete_if { |piece| piece.location == to }
      # Force AI to continue analysis
      force_analysis = true
    end
    # Move piece
    position[from[0]][from[1]] = "."
    position[to[0]][to[1]] = moving_piece.icon
    moving_piece.location = to
    # Switch active player
    next_player = opp
    {
      :position => position,
      :player => next_player,
      :pieces => pieces,
      :force_analysis => force_analysis
    }
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
    # print "Your pieces: "
    # puts piece_list.map { |piece| "#{piece.icon} at #{piece.location}"}
    move = nil
    while move == nil
      puts
      print "Enter move in algebraic notation: "
      move_labels = gets.chomp.split("-")
      if move_labels.length != 2 || move_labels[0].length != 2 || move_labels[1].length != 2
        puts "I don't understand that move."
        puts "Please use algebraic notation, e.g. 'e2-e4'."
      else
        from = coordinates(move_labels[0])
        to = coordinates(move_labels[1])
        if !from
          puts "I don't understand #{move_labels[0]} as a position."
        elsif !to
          puts "I don't understand #{move_labels[1]} as a position."
        else
          piece = @current_state[:pieces][:human].find { |p| p.location == from }
          if !piece
            puts "You have no piece at #{move_labels[0]}"
          elsif !piece.legal_moves(@current_state).include?([from, to])
            puts "That's not a legal destination."
            puts
            binding.pry
          else
            move = [from, to]
          end
        end
      end
    end
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
    # pieces[player].empty?
    king = pieces[player].find { |piece| piece.class == King }
    !king
  end

  # Check whether game has been lost by player to move
  def lost?(state)
    pieces = state[:pieces]
    player = state[:player]
    # pieces[player].empty?
    king = pieces[player].find { |piece| piece.class == King }
    !king
  end

  ## Displays

  # Print the entire board (only works for current position)
  def display_position
    side = " \u2551"
    puts " \u2554" + "\u2550" * 16 + "\u2557"
    current_position.each do |row|
      row_string = row.join(" ")
      puts side + row_string + side
    end
    puts " \u255A" + "\u2550" * 16 + "\u255D"
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





