# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Forfeit" do
  # Invariant: A player may forfeit only during their turn
  describe "turn restriction" do
    it "allows current player to forfeit" do
      game = create_game
      response = forfeit(game["id"], "X")

      expect(response.status).to eq(200)
    end

    it "rejects forfeit from non-current player" do
      game = create_game
      response = forfeit(game["id"], "O")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("not_your_turn")
    end

    it "allows O to forfeit on their turn" do
      game = create_game
      make_move(game["id"], 0, 0, "X")
      response = forfeit(game["id"], "O")

      expect(response.status).to eq(200)
    end
  end

  # Invariant: A player may forfeit only while the game is in progress
  describe "game state restriction" do
    it "rejects forfeit after game is won" do
      game = create_game
      # X wins with top row
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 1, 0, "O")
      make_move(game["id"], 0, 1, "X")
      make_move(game["id"], 1, 1, "O")
      make_move(game["id"], 0, 2, "X") # X wins

      response = forfeit(game["id"], "O")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("game_over")
    end
  end

  # Invariant: On forfeit, the forfeiting player loses immediately
  # Invariant: On forfeit, the opponent wins immediately
  describe "outcome" do
    it "declares opponent as winner when X forfeits" do
      game = create_game
      response = forfeit(game["id"], "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_forfeits")
      expect(final_game["winner"]).to eq("O")
    end

    it "declares opponent as winner when O forfeits" do
      game = create_game
      make_move(game["id"], 0, 0, "X")
      response = forfeit(game["id"], "O")

      final_game = response.body
      expect(final_game["status"]).to eq("o_forfeits")
      expect(final_game["winner"]).to eq("X")
    end
  end

  # Invariant: Forfeit ends the game — no further moves are allowed
  describe "game termination" do
    it "rejects moves after forfeit" do
      game = create_game
      forfeit(game["id"], "X")

      response = make_move(game["id"], 0, 0, "O")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("game_over")
    end

    it "rejects additional forfeits after forfeit" do
      game = create_game
      forfeit(game["id"], "X")

      response = forfeit(game["id"], "O")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("game_over")
    end
  end
end
