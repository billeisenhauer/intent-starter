# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Move Validity" do
  # Invariant: A move must target an empty cell
  describe "occupied cell rejection" do
    it "rejects move to cell occupied by same player" do
      game = create_game
      make_move(game["id"], 0, 0, "X")
      make_move(game["id"], 1, 1, "O")
      response = make_move(game["id"], 0, 0, "X")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("cell_occupied")
    end

    it "rejects move to cell occupied by opponent" do
      game = create_game
      make_move(game["id"], 0, 0, "X")
      response = make_move(game["id"], 0, 0, "O")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("cell_occupied")
    end
  end

  # Invariant: A move outside the board boundaries is rejected
  describe "boundary validation" do
    it "rejects negative row" do
      game = create_game
      response = make_move(game["id"], -1, 0, "X")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("invalid_position")
    end

    it "rejects negative column" do
      game = create_game
      response = make_move(game["id"], 0, -1, "X")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("invalid_position")
    end

    it "rejects row greater than 2" do
      game = create_game
      response = make_move(game["id"], 3, 0, "X")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("invalid_position")
    end

    it "rejects column greater than 2" do
      game = create_game
      response = make_move(game["id"], 0, 3, "X")

      expect(response.status).to eq(400)
      expect(response.body["error"]).to eq("invalid_position")
    end

    it "accepts move at (0, 0)" do
      game = create_game
      response = make_move(game["id"], 0, 0, "X")

      expect(response.status).to eq(200)
    end

    it "accepts move at (2, 2)" do
      game = create_game
      response = make_move(game["id"], 2, 2, "X")

      expect(response.status).to eq(200)
    end
  end

  # Invariant: A valid move places the current player's mark on the board
  describe "mark placement" do
    it "places X mark on the board" do
      game = create_game
      response = make_move(game["id"], 0, 0, "X")

      updated_game = response.body
      expect(updated_game["board"][0]).to eq("X")
    end

    it "places O mark on the board" do
      game = create_game
      make_move(game["id"], 0, 0, "X")
      response = make_move(game["id"], 1, 1, "O")

      updated_game = response.body
      expect(updated_game["board"][4]).to eq("O") # Center cell (1,1) = index 4
    end

    it "preserves existing marks when placing new ones" do
      game = create_game
      make_move(game["id"], 0, 0, "X")
      response = make_move(game["id"], 2, 2, "O")

      updated_game = response.body
      expect(updated_game["board"][0]).to eq("X")
      expect(updated_game["board"][8]).to eq("O")
    end
  end
end
