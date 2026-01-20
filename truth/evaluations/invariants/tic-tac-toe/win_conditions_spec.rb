# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Win Conditions" do
  # Invariant: Three identical marks in a horizontal row wins
  describe "horizontal wins" do
    it "detects top row win for X" do
      game = create_game
      # X(0,0), O(1,0), X(0,1), O(1,1), X(0,2)
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 1, 0, "O")
      make_move(game["id"], 0, 1, "X")
      make_move(game["id"], 1, 1, "O")
      response = make_move(game["id"], 0, 2, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
      expect(final_game["winner"]).to eq("X")
    end

    it "detects middle row win for X" do
      game = create_game
      # X(1,0), O(0,0), X(1,1), O(0,1), X(1,2)
      make_move(game["id"], 1, 0, "X")
      make_move(game["id"], 0, 0, "O")
      make_move(game["id"], 1, 1, "X")
      make_move(game["id"], 0, 1, "O")
      response = make_move(game["id"], 1, 2, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
    end

    it "detects bottom row win for X" do
      game = create_game
      # X(2,0), O(0,0), X(2,1), O(0,1), X(2,2)
      make_move(game["id"], 2, 0, "X")
      make_move(game["id"], 0, 0, "O")
      make_move(game["id"], 2, 1, "X")
      make_move(game["id"], 0, 1, "O")
      response = make_move(game["id"], 2, 2, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
    end
  end

  # Invariant: Three identical marks in a vertical column wins
  describe "vertical wins" do
    it "detects left column win for X" do
      game = create_game
      # X(0,0), O(0,1), X(1,0), O(1,1), X(2,0)
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 0, 1, "O")
      make_move(game["id"], 1, 0, "X")
      make_move(game["id"], 1, 1, "O")
      response = make_move(game["id"], 2, 0, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
    end

    it "detects middle column win for X" do
      game = create_game
      # X(0,1), O(0,0), X(1,1), O(1,0), X(2,1)
      make_move(game["id"], 0, 1, "X")
      make_move(game["id"], 0, 0, "O")
      make_move(game["id"], 1, 1, "X")
      make_move(game["id"], 1, 0, "O")
      response = make_move(game["id"], 2, 1, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
    end

    it "detects right column win for X" do
      game = create_game
      # X(0,2), O(0,0), X(1,2), O(1,0), X(2,2)
      make_move(game["id"], 0, 2, "X")
      make_move(game["id"], 0, 0, "O")
      make_move(game["id"], 1, 2, "X")
      make_move(game["id"], 1, 0, "O")
      response = make_move(game["id"], 2, 2, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
    end
  end

  # Invariant: Three identical marks in a diagonal wins
  describe "diagonal wins" do
    it "detects main diagonal win for X" do
      game = create_game
      # X(0,0), O(0,1), X(1,1), O(0,2), X(2,2)
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 0, 1, "O")
      make_move(game["id"], 1, 1, "X")
      make_move(game["id"], 0, 2, "O")
      response = make_move(game["id"], 2, 2, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
    end

    it "detects anti-diagonal win for X" do
      game = create_game
      # X(0,2), O(0,0), X(1,1), O(1,0), X(2,0)
      make_move(game["id"], 0, 2, "X")
      make_move(game["id"], 0, 0, "O")
      make_move(game["id"], 1, 1, "X")
      make_move(game["id"], 1, 0, "O")
      response = make_move(game["id"], 2, 0, "X")

      final_game = response.body
      expect(final_game["status"]).to eq("x_wins")
    end
  end

  # Verify O can also win
  describe "O wins" do
    it "detects win for O" do
      game = create_game
      # X(0,0), O(1,0), X(0,1), O(1,1), X(2,2), O(1,2)
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 1, 0, "O")
      make_move(game["id"], 0, 1, "X")
      make_move(game["id"], 1, 1, "O")
      make_move(game["id"], 2, 2, "X")
      response = make_move(game["id"], 1, 2, "O")

      final_game = response.body
      expect(final_game["status"]).to eq("o_wins")
      expect(final_game["winner"]).to eq("O")
    end
  end

  # Invariant: The first player to achieve a winning condition wins
  it "detects win immediately when achieved" do
    game = create_game
    make_move(game["id"], 0, 0, "X")
    make_move(game["id"], 1, 0, "O")
    make_move(game["id"], 0, 1, "X")
    make_move(game["id"], 1, 1, "O")

    # Before winning move
    current_state = get_game(game["id"])
    expect(current_state["status"]).to eq("in_progress")

    # Winning move
    response = make_move(game["id"], 0, 2, "X")
    final_game = response.body
    expect(final_game["status"]).to eq("x_wins")
  end
end
