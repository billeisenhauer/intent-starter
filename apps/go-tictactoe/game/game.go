package game

import (
	"errors"
	"sync"

	"github.com/google/uuid"
)

// Player represents X or O
type Player string

const (
	PlayerX Player = "X"
	PlayerO Player = "O"
)

// Status represents the game state
type Status string

const (
	StatusInProgress Status = "in_progress"
	StatusXWins      Status = "x_wins"
	StatusOWins      Status = "o_wins"
	StatusDraw       Status = "draw"
	StatusXForfeits  Status = "x_forfeits"
	StatusOForfeits  Status = "o_forfeits"
)

// Error types for invalid operations
var (
	ErrNotYourTurn     = errors.New("not_your_turn")
	ErrCellOccupied    = errors.New("cell_occupied")
	ErrInvalidPosition = errors.New("invalid_position")
	ErrGameOver        = errors.New("game_over")
)

// Game represents a tic-tac-toe game
type Game struct {
	ID            string   `json:"id"`
	Board         [9]string `json:"board"`
	CurrentPlayer Player   `json:"currentPlayer"`
	Status        Status   `json:"status"`
	Winner        *Player  `json:"winner,omitempty"`
}

// New creates a new game with X as the first player
func New() *Game {
	return &Game{
		ID:            uuid.New().String(),
		Board:         [9]string{"", "", "", "", "", "", "", "", ""},
		CurrentPlayer: PlayerX,
		Status:        StatusInProgress,
	}
}

// Move places a mark on the board
func (g *Game) Move(row, col int, player Player) error {
	// Check if game is over
	if g.Status != StatusInProgress {
		return ErrGameOver
	}

	// Validate position
	if row < 0 || row > 2 || col < 0 || col > 2 {
		return ErrInvalidPosition
	}

	// Check turn
	if player != g.CurrentPlayer {
		return ErrNotYourTurn
	}

	// Calculate board index
	index := row*3 + col

	// Check if cell is occupied
	if g.Board[index] != "" {
		return ErrCellOccupied
	}

	// Place the mark
	g.Board[index] = string(player)

	// Check for win
	if g.checkWin(player) {
		if player == PlayerX {
			g.Status = StatusXWins
		} else {
			g.Status = StatusOWins
		}
		g.Winner = &player
		return nil
	}

	// Check for draw
	if g.isBoardFull() {
		g.Status = StatusDraw
		return nil
	}

	// Switch player
	if g.CurrentPlayer == PlayerX {
		g.CurrentPlayer = PlayerO
	} else {
		g.CurrentPlayer = PlayerX
	}

	return nil
}

// Forfeit allows the current player to forfeit the game
func (g *Game) Forfeit(player Player) error {
	// Check if game is over
	if g.Status != StatusInProgress {
		return ErrGameOver
	}

	// Check turn
	if player != g.CurrentPlayer {
		return ErrNotYourTurn
	}

	// Set forfeit status and winner
	if player == PlayerX {
		g.Status = StatusXForfeits
		opponent := PlayerO
		g.Winner = &opponent
	} else {
		g.Status = StatusOForfeits
		opponent := PlayerX
		g.Winner = &opponent
	}

	return nil
}

// checkWin checks if the given player has won
func (g *Game) checkWin(player Player) bool {
	mark := string(player)

	// Winning combinations (rows, columns, diagonals)
	lines := [][3]int{
		// Rows
		{0, 1, 2}, {3, 4, 5}, {6, 7, 8},
		// Columns
		{0, 3, 6}, {1, 4, 7}, {2, 5, 8},
		// Diagonals
		{0, 4, 8}, {2, 4, 6},
	}

	for _, line := range lines {
		if g.Board[line[0]] == mark &&
			g.Board[line[1]] == mark &&
			g.Board[line[2]] == mark {
			return true
		}
	}
	return false
}

// isBoardFull checks if all cells are occupied
func (g *Game) isBoardFull() bool {
	for _, cell := range g.Board {
		if cell == "" {
			return false
		}
	}
	return true
}

// BoardSlice returns board as a slice for JSON serialization
func (g *Game) BoardSlice() []string {
	return g.Board[:]
}

// Store manages game instances
type Store struct {
	games map[string]*Game
	mu    sync.RWMutex
}

// NewStore creates a new game store
func NewStore() *Store {
	return &Store{
		games: make(map[string]*Game),
	}
}

// Create creates a new game and stores it
func (s *Store) Create() *Game {
	s.mu.Lock()
	defer s.mu.Unlock()

	game := New()
	s.games[game.ID] = game
	return game
}

// Get retrieves a game by ID
func (s *Store) Get(id string) (*Game, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	game, ok := s.games[id]
	return game, ok
}
