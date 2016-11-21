require_relative 'minimax'
require_relative 'game'

class Freecell < Game

  ## Constants and initialization

  CARD_ICON = [" ", "A", "2", "3", "4", "5", "6",
          "7", "8", "9", "T", "J", "Q", "K"]

  # Initialize new game
  def initialize
    player = :human
    position = deal_cards
    # State is a hash consisting of the current position and the
    # Player currently to move
    @current_state = { :position => position, :player => player }
  end

  # Get abbreviation for card
  def icon(value)
    self.class::CARD_ICON[value]
  end

  # Get value for card abbreviation
  def value(icon)
    self.class::CARD_ICON.index(icon)
  end

  # Deal cards into tableau in random order
  def deal_cards
    # Create tableau
    position = Array.new(3) { Array.new(13, 0)}
    # Shuffle cards
    @cards = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13].shuffle
    # Deal cards onto tableau
    column = 0
    row = 1
    @cards.each do |card|
      position[column][row] = card
      column += 1
      if column > 2
        column = 0
        row += 1
      end
    end
    # Return the resulting position
    position
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

  ## 2. Game-specific methods to make moves

  # Legal moves for minimax algorithm
  # Returns array containing list of legal moves in given state
  # Move is two-element array containing from coordinates and to
  # Coordinates
  def legal_moves(state)
    moves = []
    # Loop over all movable cards
    cards = movable_cards(state)
    cards.each do |card|
      # Loop over legal moves for this card 
      legal_destinations(card).each do |dest|
        # Add move to list
        moves << [card, dest]
      end
    end
    moves
  end

  def legal_destinations(cell)
    destinations = []
    # If cell is not a freecell, add first empty freecell
    if cell[1] > 0
      if first_empty_freecell
        destinations << freecells[first_empty_freecell]
      end
    end
  end

  def movable_cards(state)
    position = current_position
    movable_list = []
    # Get cards on bottom of columns
    position.each_with_index do |column, index|
      row = bottom(column)
      if row
        movable_list << [index, row]
      end
    end
    # Get occupied freecells
    freecells.each do |cell|
      if cell_value(cell) > 0
        movable_list << cell
      end
    end
    # Return result
    movable_list
  end

  def freecells
    [[0, 0], [1, 0]]
  end

  def first_empty_freecell
      freecells.index { |freecell| cell_value(freecell) == 0 }
  end

  def cell_value(cell)
    current_position[cell[0]][cell[1]]
  end


  # Returns row coordinate of bottom card of a column
  # Or nil if column is empty
  def bottom(column)
    index = column.last(12).index(0)
    if index == 0
      return nil
    end
    return index
  end

  # Given state and move, return resulting state after move is made
  # That means updating the position, and also (usually) switching
  # the player to the opponent
  def next_state(state, move)
    # Fill this in
  end


  # Return true if card with specific value can move
  # Used when checking player move
  def can_move?(card_value)
    list = movable_cards(@current_state)
    movable_values = list.map { |cell| cell_value(cell) }
    movable_value.include?(card_value)
  end

  # Get the player's move and make it
  def get_move
    # Fill this in.  Sample code:
    puts
    display_position
    move = nil
    until move != nil
      puts
      print "Enter card to move (A-K): "
      move_string = gets.chomp.upcase
      card_value = value(move_string)
      if card_value
        if can_move?(card_value)
          puts "Location can be a card on bottom of column, "
          puts "Or F for freecell, or B for build pile."
          print "Enter location to move to: "
          location = gets.chomp.upcase
          if location.length == 1
            case "F"
              # Free cell
            case "B"
              # Build pile
            else
              # Bottom of column
            end
          else
            puts "location must be a single character. "
          end
        else
          puts "That card can't move right now. "
        end
      else
        puts "I don't recognize that card. "
      end
    end
    make_move(move)
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
  def display_position
    # Turn the tableau vertically
    tableau = @current_state[:position].transpose
    first_row = true
    # Print each row, with line after top row
    tableau.each do |row|
      row_icons = row.map { |card| self.class::CARD_ICON[card] }
      puts row_icons.join(" ")
      if first_row
        puts "-----"
        first_row = false
      end
    end
  end

  # Display the computer's move
  def display_computer_move(move)
    # Fill this in
  end

end

# Driver code
game = Freecell.new
minimax = Minimax.new(game)
game.minimax = minimax

p game.legal_moves(game.current_state)



while !game.done?(game.current_state)
  game.get_move
  if game.won?(game.current_state)
    puts "I win!!"
  else
    game.computer_move
    puts "You win!" if game.won?(game.current_state)
  end
end
