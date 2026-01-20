# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Game Initialization" do
  # Invariant: A new game starts with an empty 3x3 board
  it "creates a game with an empty board" do
    game = create_game

    expect(game["board"]).to eq(["", "", "", "", "", "", "", "", ""])
  end

  # Invariant: X is always the first player to move
  it "sets X as the first player" do
    game = create_game

    expect(game["currentPlayer"]).to eq("X")
  end

  # Invariant: The game status starts as "in_progress"
  it "starts with status in_progress" do
    game = create_game

    expect(game["status"]).to eq("in_progress")
  end

  it "assigns a unique game ID" do
    game = create_game

    expect(game["id"]).not_to be_nil
    expect(game["id"]).not_to be_empty
  end
end
