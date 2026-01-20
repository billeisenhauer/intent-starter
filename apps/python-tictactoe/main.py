"""FastAPI tic-tac-toe server."""

import os
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel

from game import Game, GameStore, Player, NotYourTurn, CellOccupied, InvalidPosition, GameOver

app = FastAPI(title="Tic-Tac-Toe (Python)")
store = GameStore()


class MoveRequest(BaseModel):
    row: int
    col: int
    player: str


class ForfeitRequest(BaseModel):
    player: str


class ErrorResponse(BaseModel):
    error: str


@app.post("/game", status_code=201)
def create_game():
    """Create a new game."""
    game = store.create()
    return game.to_dict()


@app.get("/game/{game_id}")
def get_game(game_id: str):
    """Get current game state."""
    game = store.get(game_id)
    if not game:
        raise HTTPException(status_code=404, detail="game not found")
    return game.to_dict()


@app.post("/game/{game_id}/move")
def make_move(game_id: str, move: MoveRequest):
    """Make a move."""
    game = store.get(game_id)
    if not game:
        raise HTTPException(status_code=404, detail="game not found")

    try:
        player = Player(move.player)
    except ValueError:
        return JSONResponse(status_code=400, content={"error": "invalid_player"})

    try:
        game.move(move.row, move.col, player)
    except NotYourTurn:
        return JSONResponse(status_code=400, content={"error": "not_your_turn"})
    except CellOccupied:
        return JSONResponse(status_code=400, content={"error": "cell_occupied"})
    except InvalidPosition:
        return JSONResponse(status_code=400, content={"error": "invalid_position"})
    except GameOver:
        return JSONResponse(status_code=400, content={"error": "game_over"})

    return game.to_dict()


@app.post("/game/{game_id}/forfeit")
def forfeit_game(game_id: str, forfeit: ForfeitRequest):
    """Forfeit the game."""
    game = store.get(game_id)
    if not game:
        raise HTTPException(status_code=404, detail="game not found")

    try:
        player = Player(forfeit.player)
    except ValueError:
        return JSONResponse(status_code=400, content={"error": "invalid_player"})

    try:
        game.forfeit(player)
    except NotYourTurn:
        return JSONResponse(status_code=400, content={"error": "not_your_turn"})
    except GameOver:
        return JSONResponse(status_code=400, content={"error": "game_over"})

    return game.to_dict()


# Serve static files
app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/")
def read_root():
    """Serve the main HTML page."""
    return FileResponse("static/index.html")


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8082))
    uvicorn.run(app, host="0.0.0.0", port=port)
