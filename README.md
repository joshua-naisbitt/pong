# Pong

A minimal two-player Pong clone built in Godot 4 (GDScript).

## Controls

- Player 1: `W` / `S`
- Player 2: `Up` / `Down`

First to keep missing loses a point; there's no win condition or menu — it just keeps scoring.

## Requirements

- [Godot 4](https://godotengine.org/) (developed against 4.7.2)

## Running

Open `project.godot` in the Godot editor and press Play, or run headless from the command line:

```
godot --path .
```

## Project layout

- `project.godot` — engine config, viewport fixed at 800x600
- `scenes/Main.tscn` — the only scene: both paddles, the ball, and the score labels
- `scripts/main.gd` — score tracking
- `scripts/paddle.gd` — shared by both paddles, distinguished by exported key bindings
- `scripts/ball.gd` — movement and manual AABB collision against the paddles and screen edges

See [CLAUDE.md](CLAUDE.md) for more implementation detail.
