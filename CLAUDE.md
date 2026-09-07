# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A minimal Pong clone built in Godot 4 (GDScript). Two-player, local, keyboard-only.

## Environment note

This session runs inside a Flatpak sandbox (Freedesktop SDK runtime) that does not itself have
`godot`, `dnf`, or `flatpak` on its `PATH`. The actual Fedora host does. Reach the host with
`flatpak-spawn --host -- <command>`, e.g. `flatpak-spawn --host -- godot --version`. The
sandbox's `/tmp` is also not the host's `/tmp` — write test artifacts under the project directory
(which is bind-mounted) rather than `/tmp` if a host process needs to read them back.

Godot is installed via `dnf` (not Flatpak) at the current stable version. Reinstall/upgrade with:

```
flatpak-spawn --host -- sudo dnf install -y godot
```

(Sudo needs an interactive password; use `pkexec dnf install -y godot` instead if running
non-interactively, since it triggers a graphical polkit prompt rather than reading stdin.)

## Commands

Run the game (opens a window on the host display):
```
flatpak-spawn --host -- godot --path /home/jjnaisbitt/Developer/pog
```

Headless check for script/parse errors (no window, exits after N frames — useful for verifying
changes without a display):
```
flatpak-spawn --host -- godot --headless --path /home/jjnaisbitt/Developer/pog --quit-after 30
```
Any `SCRIPT ERROR:` or `ERROR:` lines in the output indicate a problem; clean output means the
scene loaded and ran without exceptions.

There is no build step, package manager, or test suite — it's a single Godot project directory.

## Architecture

- `project.godot` — engine config. `run/main_scene` points at `scenes/Main.tscn`. Viewport is
  fixed at 800x600.
- `scenes/Main.tscn` — the only scene. Contains both paddles, the ball, the center line/background
  visuals, and the two score labels, all as direct children of the root `Main` node.
- `scripts/main.gd` (on the `Main` root node) — owns the score. Exposes `on_goal(scorer: int)`,
  called by the ball when it exits the left/right edge of the screen.
- `scripts/paddle.gd` (on `Paddle1`/`Paddle2`) — one script shared by both paddles, distinguished
  only by exported `up_key`/`down_key` values set per-instance in the `.tscn` (WASD for Paddle1,
  arrow keys for Paddle2). Reads `Input.is_physical_key_pressed` directly rather than using the
  project input map — there are no custom actions defined in `project.godot`.
- `scripts/ball.gd` (on `Ball`) — owns its own velocity and does its own AABB collision math
  against `paddle.get_rect()` for both paddles each frame, and against the top/bottom screen
  edges. There are no physics bodies/collision shapes/layers anywhere in this project — paddles
  and the ball are plain `Node2D`s with a `ColorRect` child for visuals, and all collision is
  manual `Rect2` intersection in `_process`. Keep new gameplay code consistent with this rather
  than introducing `CharacterBody2D`/`Area2D` physics, to avoid mixing manual and physics-driven
  collision in the same scene.
- Scoring/serve direction: `ball.launch(direction)` recenters the ball and serves it toward the
  player who just conceded (see `main.gd::on_goal`).

Node lookups between scripts go through `get_parent()` from the ball (to reach `main.paddle1`/
`main.paddle2`) and `@onready var` from `main.gd` (to reach `$Paddle1`, `$Paddle2`, `$Ball`,
`$ScoreLabel1`, `$ScoreLabel2`). If you rename nodes in `Main.tscn`, update both.
