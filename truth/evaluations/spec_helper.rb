# frozen_string_literal: true

require "faraday"
require "json"

# Base URL for the implementation under test
# Set via environment variable: BASE_URL=http://localhost:8081
def base_url
  ENV.fetch("BASE_URL", "http://localhost:8080")
end

# HTTP client for API calls
def client
  @client ||= Faraday.new(url: base_url) do |f|
    f.request :json
    f.response :json
    f.adapter Faraday.default_adapter
  end
end

# Helper to create a new game
def create_game
  response = client.post("/game")
  expect(response.status).to eq(201)
  response.body
end

# Helper to make a move
def make_move(game_id, row, col, player)
  client.post("/game/#{game_id}/move") do |req|
    req.body = { row: row, col: col, player: player }
  end
end

# Helper to get game state
def get_game(game_id)
  response = client.get("/game/#{game_id}")
  expect(response.status).to eq(200)
  response.body
end

# Helper to forfeit
def forfeit(game_id, player)
  client.post("/game/#{game_id}/forfeit") do |req|
    req.body = { player: player }
  end
end

# Helper to play a sequence of moves
# Format: "X(0,0), O(1,1), X(2,2)"
def play_moves(game_id, moves_string)
  moves_string.split(", ").each do |move|
    match = move.match(/([XO])\((\d),(\d)\)/)
    next unless match

    player, row, col = match[1], match[2].to_i, match[3].to_i
    response = make_move(game_id, row, col, player)
    expect(response.status).to eq(200), "Move #{move} failed: #{response.body}"
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
