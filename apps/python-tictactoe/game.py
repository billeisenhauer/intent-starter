"""Tic-Tac-Toe game logic."""

from dataclasses import dataclass, field
from enum import Enum
from typing import Optional
import uuid


class Player(str, Enum):
    X = "X"
    O = "O"


class Status(str, Enum):
    IN_PROGRESS = "in_progress"
    X_WINS = "x_wins"
    O_WINS = "o_wins"
    DRAW = "draw"
    X_FORFEITS = "x_forfeits"
    O_FORFEITS = "o_forfeits"


class NotYourTurn(Exception):
    """Raised when a player tries to move out of turn."""
    pass


class CellOccupied(Exception):
    """Raised when a player tries to move to an occupied cell."""
    pass


class InvalidPosition(Exception):
    """Raised when a move is outside board boundaries."""
    pass


class GameOver(Exception):
    """Raised when a move is attempted after the game has ended."""
    pass


@dataclass
class Game:
    """Represents a tic-tac-toe game."""

    id: str = field(default_factory=lambda: str(uuid.uuid4()))
    board: list[str] = field(default_factory=lambda: [""] * 9)
    current_player: Player = Player.X
    status: Status = Status.IN_PROGRESS
    winner: Optional[Player] = None

    def move(self, row: int, col: int, player: Player) -> None:
        """Make a move on the board."""
        # Check if game is over
        if self.status != Status.IN_PROGRESS:
            raise GameOver()

        # Validate position
        if row < 0 or row > 2 or col < 0 or col > 2:
            raise InvalidPosition()

        # Check turn
        if player != self.current_player:
            raise NotYourTurn()

        # Calculate board index
        index = row * 3 + col

        # Check if cell is occupied
        if self.board[index] != "":
            raise CellOccupied()

        # Place the mark
        self.board[index] = player.value

        # Check for win
        if self._check_win(player):
            self.status = Status.X_WINS if player == Player.X else Status.O_WINS
            self.winner = player
            return

        # Check for draw
        if self._is_board_full():
            self.status = Status.DRAW
            return

        # Switch player
        self.current_player = Player.O if self.current_player == Player.X else Player.X

    def forfeit(self, player: Player) -> None:
        """Current player forfeits the game."""
        # Check if game is over
        if self.status != Status.IN_PROGRESS:
            raise GameOver()

        # Check turn
        if player != self.current_player:
            raise NotYourTurn()

        # Set forfeit status and winner
        if player == Player.X:
            self.status = Status.X_FORFEITS
            self.winner = Player.O
        else:
            self.status = Status.O_FORFEITS
            self.winner = Player.X

    def _check_win(self, player: Player) -> bool:
        """Check if the given player has won."""
        mark = player.value

        # Winning combinations (rows, columns, diagonals)
        lines = [
            # Rows
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            # Columns
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            # Diagonals
            [0, 4, 8], [2, 4, 6],
        ]

        for line in lines:
            if all(self.board[i] == mark for i in line):
                return True
        return False

    def _is_board_full(self) -> bool:
        """Check if all cells are occupied."""
        return all(cell != "" for cell in self.board)

    def to_dict(self) -> dict:
        """Convert game state to dictionary for JSON serialization."""
        result = {
            "id": self.id,
            "board": self.board,
            "currentPlayer": self.current_player.value,
            "status": self.status.value,
        }
        if self.winner:
            result["winner"] = self.winner.value
        return result


class GameStore:
    """Manages game instances."""

    def __init__(self):
        self._games: dict[str, Game] = {}

    def create(self) -> Game:
        """Create a new game and store it."""
        game = Game()
        self._games[game.id] = game
        return game

    def get(self, game_id: str) -> Optional[Game]:
        """Retrieve a game by ID."""
        return self._games.get(game_id)
