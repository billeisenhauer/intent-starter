# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Draw Condition" do
  # Invariant: If all nine cells are filled and no player has won, the game is a draw
  it "detects draw when board is full with no winner" do
    game = create_game

    # Play a game that results in a draw:
    # X O X
    # X X O
    # O X O
    make_move(game["id"], 0, 0, "X") # X at top-left
    make_move(game["id"], 0, 1, "O") # O at top-middle
    make_move(game["id"], 0, 2, "X") # X at top-right
    make_move(game["id"], 1, 1, "O") # O at center
    make_move(game["id"], 1, 0, "X") # X at middle-left
    make_move(game["id"], 2, 0, "O") # O at bottom-left
    make_move(game["id"], 1, 2, "X") # X at middle-right
    make_move(game["id"], 2, 2, "O") # O at bottom-right
    response = make_move(game["id"], 2, 1, "X") # X at bottom-middle

    final_game = response.body
    expect(final_game["status"]).to eq("draw")
  end

  # Invariant: A draw can only occur when the board is full
  it "does not declare draw before board is full" do
    game = create_game

    # Make some moves but don't fill the board
    make_move(game["id"], 0, 0, "X")
    make_move(game["id"], 0, 1, "O")
    make_move(game["id"], 0, 2, "X")
    response = make_move(game["id"], 1, 0, "O")

    current_game = response.body
    expect(current_game["status"]).to eq("in_progress")
  end

  it "does not have a winner on draw" do
    game = create_game

    # Play a draw game
    make_move(game["id"], 0, 0, "X")
    make_move(game["id"], 0, 1, "O")
    make_move(game["id"], 0, 2, "X")
    make_move(game["id"], 1, 1, "O")
    make_move(game["id"], 1, 0, "X")
    make_move(game["id"], 2, 0, "O")
    make_move(game["id"], 1, 2, "X")
    make_move(game["id"], 2, 2, "O")
    response = make_move(game["id"], 2, 1, "X")

    final_game = response.body
    expect(final_game["winner"]).to be_nil
  end
end
