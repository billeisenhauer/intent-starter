package game

import (
	"testing"
)

func TestNewGame(t *testing.T) {
	g := New()

	// Board should be empty
	for i, cell := range g.Board {
		if cell != "" {
			t.Errorf("Cell %d should be empty, got %s", i, cell)
		}
	}

	// X should be first
	if g.CurrentPlayer != PlayerX {
		t.Errorf("First player should be X, got %s", g.CurrentPlayer)
	}

	// Status should be in_progress
	if g.Status != StatusInProgress {
		t.Errorf("Status should be in_progress, got %s", g.Status)
	}
}

func TestXMovesFirst(t *testing.T) {
	g := New()

	// X should be able to move
	err := g.Move(0, 0, PlayerX)
	if err != nil {
		t.Errorf("X should be able to move first, got error: %v", err)
	}
}

func TestOCannotMoveFirst(t *testing.T) {
	g := New()

	err := g.Move(0, 0, PlayerO)
	if err != ErrNotYourTurn {
		t.Errorf("O should not be able to move first, expected ErrNotYourTurn, got: %v", err)
	}
}

func TestTurnAlternation(t *testing.T) {
	g := New()

	g.Move(0, 0, PlayerX)
	if g.CurrentPlayer != PlayerO {
		t.Errorf("After X moves, current player should be O, got %s", g.CurrentPlayer)
	}

	g.Move(1, 1, PlayerO)
	if g.CurrentPlayer != PlayerX {
		t.Errorf("After O moves, current player should be X, got %s", g.CurrentPlayer)
	}
}

func TestCannotMoveTwice(t *testing.T) {
	g := New()

	g.Move(0, 0, PlayerX)
	err := g.Move(1, 1, PlayerX)
	if err != ErrNotYourTurn {
		t.Errorf("X should not be able to move twice, expected ErrNotYourTurn, got: %v", err)
	}
}

func TestCellOccupied(t *testing.T) {
	g := New()

	g.Move(0, 0, PlayerX)
	err := g.Move(0, 0, PlayerO)
	if err != ErrCellOccupied {
		t.Errorf("Should not be able to move to occupied cell, expected ErrCellOccupied, got: %v", err)
	}
}

func TestInvalidPosition(t *testing.T) {
	tests := []struct {
		row, col int
	}{
		{-1, 0},
		{0, -1},
		{3, 0},
		{0, 3},
	}

	for _, tt := range tests {
		g := New()
		err := g.Move(tt.row, tt.col, PlayerX)
		if err != ErrInvalidPosition {
			t.Errorf("Move(%d, %d) should be invalid position, got: %v", tt.row, tt.col, err)
		}
	}
}

func TestHorizontalWin(t *testing.T) {
	g := New()

	// X wins with top row
	g.Move(0, 0, PlayerX)
	g.Move(1, 0, PlayerO)
	g.Move(0, 1, PlayerX)
	g.Move(1, 1, PlayerO)
	g.Move(0, 2, PlayerX)

	if g.Status != StatusXWins {
		t.Errorf("X should win with top row, got status: %s", g.Status)
	}
	if g.Winner == nil || *g.Winner != PlayerX {
		t.Errorf("Winner should be X")
	}
}

func TestVerticalWin(t *testing.T) {
	g := New()

	// X wins with left column
	g.Move(0, 0, PlayerX)
	g.Move(0, 1, PlayerO)
	g.Move(1, 0, PlayerX)
	g.Move(1, 1, PlayerO)
	g.Move(2, 0, PlayerX)

	if g.Status != StatusXWins {
		t.Errorf("X should win with left column, got status: %s", g.Status)
	}
}

func TestDiagonalWin(t *testing.T) {
	g := New()

	// X wins with main diagonal
	g.Move(0, 0, PlayerX)
	g.Move(0, 1, PlayerO)
	g.Move(1, 1, PlayerX)
	g.Move(0, 2, PlayerO)
	g.Move(2, 2, PlayerX)

	if g.Status != StatusXWins {
		t.Errorf("X should win with diagonal, got status: %s", g.Status)
	}
}

func TestDraw(t *testing.T) {
	g := New()

	// Play to a draw
	g.Move(0, 0, PlayerX)
	g.Move(0, 1, PlayerO)
	g.Move(0, 2, PlayerX)
	g.Move(1, 1, PlayerO)
	g.Move(1, 0, PlayerX)
	g.Move(2, 0, PlayerO)
	g.Move(1, 2, PlayerX)
	g.Move(2, 2, PlayerO)
	g.Move(2, 1, PlayerX)

	if g.Status != StatusDraw {
		t.Errorf("Game should be a draw, got status: %s", g.Status)
	}
	if g.Winner != nil {
		t.Errorf("Draw should have no winner")
	}
}

func TestNoMovesAfterWin(t *testing.T) {
	g := New()

	// X wins
	g.Move(0, 0, PlayerX)
	g.Move(1, 0, PlayerO)
	g.Move(0, 1, PlayerX)
	g.Move(1, 1, PlayerO)
	g.Move(0, 2, PlayerX)

	// Try to move after game is over
	err := g.Move(2, 2, PlayerO)
	if err != ErrGameOver {
		t.Errorf("Should not be able to move after game is over, expected ErrGameOver, got: %v", err)
	}
}
