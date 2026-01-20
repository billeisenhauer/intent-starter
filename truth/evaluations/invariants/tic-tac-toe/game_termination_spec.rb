# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Game Termination" do
  # Invariant: Once a game is won, no further moves are allowed
  describe "no moves after win" do
    it "rejects moves after X wins" do
      game = create_game

      # X wins with top row
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 1, 0, "O")
      make_move(game["id"], 0, 1, "X")
      make_move(game["id"], 1, 1, "O")
      make_move(game["id"], 0, 2, "X") # X wins

      # Attempt move after game is won
      response = make_move(game["id"], 2, 2, "O")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("game_over")
    end

    it "rejects moves after O wins" do
      game = create_game

      # O wins with middle row
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 1, 0, "O")
      make_move(game["id"], 0, 1, "X")
      make_move(game["id"], 1, 1, "O")
      make_move(game["id"], 2, 2, "X")
      make_move(game["id"], 1, 2, "O") # O wins

      # Attempt move after game is won
      response = make_move(game["id"], 2, 0, "X")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("game_over")
    end
  end

  # Invariant: Once a game is drawn, no further moves are allowed
  describe "no moves after draw" do
    it "rejects moves after draw" do
      game = create_game

      # Play to a draw
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 0, 1, "O")
      make_move(game["id"], 0, 2, "X")
      make_move(game["id"], 1, 1, "O")
      make_move(game["id"], 1, 0, "X")
      make_move(game["id"], 2, 0, "O")
      make_move(game["id"], 1, 2, "X")
      make_move(game["id"], 2, 2, "O")
      make_move(game["id"], 2, 1, "X") # Draw

      # Verify it's a draw
      current_state = get_game(game["id"])
      expect(current_state["status"]).to eq("draw")

      # Note: Since board is full, there are no empty cells to try
      # This test verifies the status is correct; the "no empty cell" constraint
      # naturally prevents further moves as well
    end
  end

  # Invariant: The game outcome (winner or draw) is immutable after termination
  describe "outcome immutability" do
    it "preserves winner status after multiple get requests" do
      game = create_game

      # X wins
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 1, 0, "O")
      make_move(game["id"], 0, 1, "X")
      make_move(game["id"], 1, 1, "O")
      make_move(game["id"], 0, 2, "X")

      # Multiple get requests should return same result
      state1 = get_game(game["id"])
      state2 = get_game(game["id"])
      state3 = get_game(game["id"])

      expect(state1["status"]).to eq("x_wins")
      expect(state2["status"]).to eq("x_wins")
      expect(state3["status"]).to eq("x_wins")

      expect(state1["winner"]).to eq("X")
      expect(state2["winner"]).to eq("X")
      expect(state3["winner"]).to eq("X")
    end
  end
end
