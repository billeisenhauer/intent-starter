package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"go-tictactoe/game"
)

var store = game.NewStore()

// GameResponse is the JSON response format
type GameResponse struct {
	ID            string   `json:"id"`
	Board         []string `json:"board"`
	CurrentPlayer string   `json:"currentPlayer"`
	Status        string   `json:"status"`
	Winner        *string  `json:"winner,omitempty"`
}

// MoveRequest is the JSON request format for moves
type MoveRequest struct {
	Row    int    `json:"row"`
	Col    int    `json:"col"`
	Player string `json:"player"`
}

// ForfeitRequest is the JSON request format for forfeits
type ForfeitRequest struct {
	Player string `json:"player"`
}

// ErrorResponse is the JSON error format
type ErrorResponse struct {
	Error string `json:"error"`
}

func gameToResponse(g *game.Game) GameResponse {
	var winner *string
	if g.Winner != nil {
		w := string(*g.Winner)
		winner = &w
	}
	return GameResponse{
		ID:            g.ID,
		Board:         g.BoardSlice(),
		CurrentPlayer: string(g.CurrentPlayer),
		Status:        string(g.Status),
		Winner:        winner,
	}
}

func createGameHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	g := store.Create()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(gameToResponse(g))
}

func getGameHandler(w http.ResponseWriter, r *http.Request, gameID string) {
	g, ok := store.Get(gameID)
	if !ok {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(ErrorResponse{Error: "game not found"})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(gameToResponse(g))
}

func makeMoveHandler(w http.ResponseWriter, r *http.Request, gameID string) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	g, ok := store.Get(gameID)
	if !ok {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(ErrorResponse{Error: "game not found"})
		return
	}

	var req MoveRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(ErrorResponse{Error: "invalid request"})
		return
	}

	player := game.Player(req.Player)
	err := g.Move(req.Row, req.Col, player)
	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(ErrorResponse{Error: err.Error()})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(gameToResponse(g))
}

func forfeitHandler(w http.ResponseWriter, r *http.Request, gameID string) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	g, ok := store.Get(gameID)
	if !ok {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(ErrorResponse{Error: "game not found"})
		return
	}

	var req ForfeitRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(ErrorResponse{Error: "invalid request"})
		return
	}

	player := game.Player(req.Player)
	err := g.Forfeit(player)
	if err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(ErrorResponse{Error: err.Error()})
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(gameToResponse(g))
}

func gameHandler(w http.ResponseWriter, r *http.Request) {
	// Parse path: /game/{id} or /game/{id}/move
	path := strings.TrimPrefix(r.URL.Path, "/game/")

	if path == "" || path == "/" {
		// POST /game - create new game
		if r.Method == http.MethodPost {
			createGameHandler(w, r)
			return
		}
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	parts := strings.Split(path, "/")
	gameID := parts[0]

	if len(parts) == 1 {
		// GET /game/{id}
		if r.Method == http.MethodGet {
			getGameHandler(w, r, gameID)
			return
		}
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	if len(parts) == 2 && parts[1] == "move" {
		// POST /game/{id}/move
		if r.Method == http.MethodPost {
			makeMoveHandler(w, r, gameID)
			return
		}
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	if len(parts) == 2 && parts[1] == "forfeit" {
		// POST /game/{id}/forfeit
		if r.Method == http.MethodPost {
			forfeitHandler(w, r, gameID)
			return
		}
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	http.NotFound(w, r)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	http.HandleFunc("/game", createGameHandler)
	http.HandleFunc("/game/", gameHandler)
	http.Handle("/", http.FileServer(http.Dir("static")))

	fmt.Printf("Go Tic-Tac-Toe server running on port %s\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
