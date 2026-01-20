# Tic-Tac-Toe

## Purpose

A two-player game where players take turns marking spaces on a 3x3 grid. The first player to align three marks horizontally, vertically, or diagonally wins. If all spaces are filled with no winner, the game ends in a draw.

## Core Identity

Tic-tac-toe is a zero-sum, perfect-information game with deterministic outcomes. The system must enforce turn order, validate moves, and detect game-ending conditions.

## Invariants

### Game Initialization
- A new game starts with an empty 3x3 board
- X is always the first player to move
- The game status starts as "in_progress"

### Turn Order
- X always moves first
- Players must alternate turns
- A player cannot move twice consecutively
- Only the current player may make a move

### Move Validity
- A move must target an empty cell
- A move to an occupied cell is rejected
- A move outside the board boundaries (0-2 for row and column) is rejected
- A valid move places the current player's mark on the board

### Win Conditions
- Three identical marks in a horizontal row wins
- Three identical marks in a vertical column wins
- Three identical marks in a diagonal wins
- The first player to achieve a winning condition wins the game

### Draw Condition
- If all nine cells are filled and no player has won, the game is a draw
- A draw can only occur when the board is full

### Game Termination
- Once a game is won, no further moves are allowed
- Once a game is drawn, no further moves are allowed
- The game outcome (winner or draw) is immutable after termination

### Forfeit
- A player may forfeit only during their turn
- A player may forfeit only while the game is in progress
- On forfeit, the forfeiting player loses immediately
- On forfeit, the opponent wins immediately
- Forfeit ends the game — no further moves are allowed
- The game outcome must indicate forfeit (status: "x_forfeits" or "o_forfeits")

## Non-Goals

- AI opponent (this is human vs human only)
- Tournament or ranking systems
- Undo functionality
- Time limits or clocks

## Status

- [x] Intent reviewed
- [ ] Evaluations written
- [ ] Implementation started
