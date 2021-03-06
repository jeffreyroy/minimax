require_relative 'minimax'
require_relative 'game'
require_relative 'checkers_pieces'
require 'pry'

# Classes
class Checkers < Game

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
      :moving_piece => nil
       }
    # Add pieces to empty board
    add_pieces
    # Intialize ai
    initialize_ai(0, 100)
  end

  # Add initial piece setup to board
  def add_pieces
    position = @current_state[:position]
    position[0] = " o o o o".split("")
    position[1] = "o o o o ".split("")
    position[2] = " o o o o".split("")
    position[3] = ". . . . ".split("")
    position[4] = " . . . .".split("")
    position[5] = "O O O O ".split("")
    position[6] = " O O O O".split("")
    position[7] = "O O O O ".split("")

    # Add checkers
    pieces= {
      :human => [ ],
      :computer => [ ]
    }
    position.each_with_index do |row, i|
      row.each_with_index do |space, j|
        if space == "o"
          pieces[:computer] << Man.new(self, [i, j], :computer)
        elsif space == "O"
          pieces[:human] << Man.new(self, [i, j], :human)
        end
      end
    end
    @current_state[:pieces] = pieces
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

  # Return row at which player's men become kings
  def end_row(player)
    player == :human ? 0 : 7
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
    !!state[:moving_piece]
  end

  ## Methods to make moves

  # Moved this to piece
  # def inbounds(destination)
  #   row = destination[0]
  #   column = destination[1]
  #   row >= 0 && row <= 7 && column >= 0 && column <= 7
  # end

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
    # Change this: Don't want to deep copy each piece here!
    pieces = Marshal.load(Marshal.dump(state[:pieces]))
    from = move[0]
    to = move[1]
    moving_piece = nil
    current_piece = pieces[player].find { |piece| piece.location == from }
    if !current_piece
      puts "ERROR--no piece to move!"
    end
    # Check for capture
    if (from[0] - to[0]).abs == 2
      # Remove enemy piece
      captured_location = [0,0]
      captured_location[0] = (from[0] + to[0]) / 2
      captured_location[1] = (from[1] + to[1]) / 2
      pieces[opp].delete_if { |piece| piece.location == captured_location }
      position[captured_location[0]][captured_location[1]] = "."
      moving_piece = to
    end
    # Move piece
    position[from[0]][from[1]] = "."
    # If at end row, turn man into king
    if to[0] == end_row(player)
      pieces[player].delete(current_piece)
      current_piece = King.new(self, from, player)
      pieces[player] << current_piece
    end
    position[to[0]][to[1]] = current_piece.icon
    current_piece.location = to
    # If not in middle of series of captures, switch active player
    next_player = moving_piece ? player : opp
    update_state = { :position => position,
      :player => next_player,
      :pieces => pieces,
      :moving_piece => moving_piece
    }
    # If no more captures, end player's move
    if moving_piece && current_piece.generate_captures(update_state).empty?
      update_state[:moving_piece] = nil
      update_state[:player] = opp
    end
    update_state
  end

  # Interpret algebraic notation as coordinates
  def coordinates(string)
    return nil if string.length != 2
    # interpret letter as column
    column = self.class::COLUMNS.index(string[0])
    row = self.class::ROWS.index(string[1])
    return nil if !column || !row
    [row, column]
  end

  # Translate coordinates into algebraic notation
  def algebraic(coordinates)
    return nil if coordinates.length != 2
    # interpret letter as column
    row = self.class::ROWS[coordinates[0]]
    column = self.class::COLUMNS[coordinates[1]]
    column + row
  end

  # For testing - get piece at location
  def get_piece(location_string)
    location = coordinates(location_string)
    pieces = @current_state[:pieces]
    piece = pieces[:human].find { |piece| piece.location == location }
    if !piece
      piece = pieces[:computer].find { |piece| piece.location == location }
    end
    piece
  end

  # For testing - print legal moves for piece at location
  def print_moves(location_string)
    piece = get_piece(location_string)
    if piece
      p piece.legal_moves(@current_state).map { |move| algebraic(move[1]) }
    else
      "No piece there. "
    end
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
    side = " \u2551"
    puts " \u2554" + "\u2550" * 16 + "\u2557"
    current_position.each do |row|
      row_string = row.join(" ")
      puts side + row_string + side
    end
    puts " \u255A" + "\u2550" * 16 + "\u255D"
  end

  def display_computer_move(move)
    puts "I move #{algebraic(move[0])}-#{algebraic(move[1])}"
  end

end

# Driver code
game = Checkers.new

complete = false
while !complete
  if game.current_state[:player] == :human
    game.get_move
  else
    game.computer_move
  end

  if game.current_state[:player] == :human && game.won?(game.current_state)
    puts "You win!!"
    complete = true
  elsif game.current_state[:player] == :computer && game.won?(game.current_state)
    puts "I win!!"
    complete = true
  elsif game.done?(game.current_state)
    puts "Draw!"
    complete = true
  end
end

game.display_position





