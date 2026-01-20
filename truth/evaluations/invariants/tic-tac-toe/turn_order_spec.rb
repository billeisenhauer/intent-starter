# frozen_string_literal: true

require_relative "../../spec_helper"

RSpec.describe "Turn Order" do
  # Invariant: X always moves first
  it "accepts X as first move" do
    game = create_game
    response = make_move(game["id"], 0, 0, "X")

    expect(response.status).to eq(200)
  end

  # Invariant: X always moves first
  it "rejects O moving first" do
    game = create_game
    response = make_move(game["id"], 0, 0, "O")

    expect(response.status).to eq(400)
    expect(response.body["error"]).to eq("not_your_turn")
  end

  # Invariant: Players must alternate turns
  it "alternates to O after X moves" do
    game = create_game
    response = make_move(game["id"], 0, 0, "X")

    updated_game = response.body
    expect(updated_game["currentPlayer"]).to eq("O")
  end

  # Invariant: Players must alternate turns
  it "alternates back to X after O moves" do
    game = create_game
    make_move(game["id"], 0, 0, "X")
    response = make_move(game["id"], 1, 1, "O")

    updated_game = response.body
    expect(updated_game["currentPlayer"]).to eq("X")
  end

  # Invariant: A player cannot move twice consecutively
  it "rejects X moving twice in a row" do
    game = create_game
    make_move(game["id"], 0, 0, "X")
    response = make_move(game["id"], 1, 1, "X")

    expect(response.status).to eq(400)
    expect(response.body["error"]).to eq("not_your_turn")
  end

  # Invariant: A player cannot move twice consecutively
  it "rejects O moving twice in a row" do
    game = create_game
    make_move(game["id"], 0, 0, "X")
    make_move(game["id"], 1, 1, "O")
    response = make_move(game["id"], 2, 2, "O")

    expect(response.status).to eq(400)
    expect(response.body["error"]).to eq("not_your_turn")
  end

  # Invariant: Only the current player may make a move
  it "only allows current player to move" do
    game = create_game

    # First turn: X can move, O cannot
    expect(make_move(game["id"], 0, 0, "X").status).to eq(200)

    # Second turn: O can move, X cannot
    expect(make_move(game["id"], 1, 0, "X").status).to eq(400)
    expect(make_move(game["id"], 1, 1, "O").status).to eq(200)

    # Third turn: X can move, O cannot
    expect(make_move(game["id"], 2, 2, "O").status).to eq(400)
    expect(make_move(game["id"], 2, 2, "X").status).to eq(200)
  end
end
