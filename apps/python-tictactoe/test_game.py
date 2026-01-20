"""Tests for tic-tac-toe game logic."""

import pytest
from game import Game, Player, Status, NotYourTurn, CellOccupied, InvalidPosition, GameOver


class TestNewGame:
    def test_board_is_empty(self):
        game = Game()
        assert game.board == [""] * 9

    def test_x_is_first_player(self):
        game = Game()
        assert game.current_player == Player.X

    def test_status_is_in_progress(self):
        game = Game()
        assert game.status == Status.IN_PROGRESS


class TestTurnOrder:
    def test_x_can_move_first(self):
        game = Game()
        game.move(0, 0, Player.X)
        assert game.board[0] == "X"

    def test_o_cannot_move_first(self):
        game = Game()
        with pytest.raises(NotYourTurn):
            game.move(0, 0, Player.O)

    def test_alternates_to_o_after_x(self):
        game = Game()
        game.move(0, 0, Player.X)
        assert game.current_player == Player.O

    def test_alternates_back_to_x_after_o(self):
        game = Game()
        game.move(0, 0, Player.X)
        game.move(1, 1, Player.O)
        assert game.current_player == Player.X

    def test_x_cannot_move_twice(self):
        game = Game()
        game.move(0, 0, Player.X)
        with pytest.raises(NotYourTurn):
            game.move(1, 1, Player.X)


class TestMoveValidity:
    def test_rejects_occupied_cell(self):
        game = Game()
        game.move(0, 0, Player.X)
        with pytest.raises(CellOccupied):
            game.move(0, 0, Player.O)

    @pytest.mark.parametrize("row,col", [(-1, 0), (0, -1), (3, 0), (0, 3)])
    def test_rejects_invalid_position(self, row, col):
        game = Game()
        with pytest.raises(InvalidPosition):
            game.move(row, col, Player.X)

    def test_accepts_valid_positions(self):
        game = Game()
        game.move(0, 0, Player.X)
        assert game.board[0] == "X"

        game2 = Game()
        game2.move(2, 2, Player.X)
        assert game2.board[8] == "X"


class TestWinConditions:
    def test_horizontal_win(self):
        game = Game()
        game.move(0, 0, Player.X)
        game.move(1, 0, Player.O)
        game.move(0, 1, Player.X)
        game.move(1, 1, Player.O)
        game.move(0, 2, Player.X)

        assert game.status == Status.X_WINS
        assert game.winner == Player.X

    def test_vertical_win(self):
        game = Game()
        game.move(0, 0, Player.X)
        game.move(0, 1, Player.O)
        game.move(1, 0, Player.X)
        game.move(1, 1, Player.O)
        game.move(2, 0, Player.X)

        assert game.status == Status.X_WINS

    def test_diagonal_win(self):
        game = Game()
        game.move(0, 0, Player.X)
        game.move(0, 1, Player.O)
        game.move(1, 1, Player.X)
        game.move(0, 2, Player.O)
        game.move(2, 2, Player.X)

        assert game.status == Status.X_WINS


class TestDraw:
    def test_draw_when_board_full_no_winner(self):
        game = Game()
        # X O X
        # X X O
        # O X O
        game.move(0, 0, Player.X)
        game.move(0, 1, Player.O)
        game.move(0, 2, Player.X)
        game.move(1, 1, Player.O)
        game.move(1, 0, Player.X)
        game.move(2, 0, Player.O)
        game.move(1, 2, Player.X)
        game.move(2, 2, Player.O)
        game.move(2, 1, Player.X)

        assert game.status == Status.DRAW
        assert game.winner is None


class TestGameTermination:
    def test_no_moves_after_win(self):
        game = Game()
        game.move(0, 0, Player.X)
        game.move(1, 0, Player.O)
        game.move(0, 1, Player.X)
        game.move(1, 1, Player.O)
        game.move(0, 2, Player.X)  # X wins

        with pytest.raises(GameOver):
            game.move(2, 2, Player.O)
