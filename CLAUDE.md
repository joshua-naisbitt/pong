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

Screenshot (opens a real window briefly, renders a couple frames, saves a PNG, quits — headless
mode won't work for this since it disables rendering entirely):
```
flatpak-spawn --host -- godot --path /home/jjnaisbitt/Developer/pog -- --screenshot=/home/jjnaisbitt/Developer/pog/screenshots/out.png
```
Handled by the `--screenshot=` arg check in the `Screenshot` autoload (`scripts/screenshot.gd`),
which reads `get_viewport().get_texture()` after two `process_frame` awaits — it lives as an
autoload (not on `main.gd`) so it fires regardless of which scene is currently active (e.g. the
title screen). `screenshots/` is gitignored — treat it as scratch output, not something to commit.

Whenever a screenshot is taken this way, always send the resulting PNG to the user (e.g. via
`SendUserFile`) so they can see it — don't just describe it in text.

There is no build step, package manager, or test suite — it's a single Godot project directory.

## Parallel agent worktrees

When starting work on a new feature, create a dedicated git worktree rather than working directly
in the main checkout, so multiple agents can work concurrently without colliding on files or
Godot's `.godot/` cache. Branch from current `master` and place the worktree under `.worktrees/`
(gitignored, so it never gets committed):

```
git worktree add .worktrees/<branch-name> -b <branch-name> master
```

Do the work in `.worktrees/<branch-name>`, using the same `flatpak-spawn --host --` commands above
but with `--path /home/jjnaisbitt/Developer/pog/.worktrees/<branch-name>`. When the feature is
merged (or abandoned), clean up:

```
git worktree remove .worktrees/<branch-name>
git branch -d <branch-name>
```

## Architecture

- `project.godot` — engine config. `run/main_scene` points at `scenes/Title.tscn`. Viewport is
  fixed at 800x600. Declares two autoloads: `Controls` (`scripts/controls.gd`) and `Screenshot`
  (`scripts/screenshot.gd`).
- `scenes/Title.tscn` — title screen (`scripts/title.gd`). Play/Settings buttons change scene to
  `Main.tscn`/`Settings.tscn` via `get_tree().change_scene_to_file`.
- `scenes/Settings.tscn` — control remapping screen (`scripts/settings.gd`). Four rebind buttons
  (P1 up/down, P2 up/down) each show the current key name (`OS.get_keycode_string`); clicking one
  enters a "listening" state and the next `_unhandled_key_input` key press is captured into that
  binding via `Controls.set_key`. Back button returns to `Title.tscn`.
- `scripts/controls.gd` (autoload singleton `Controls`) — owns the four key bindings (p1/p2 ×
  up/down), defaulting to WASD for player 1 and arrow keys for player 2. Persists to
  `user://controls.cfg` via `ConfigFile` on every change and loads it back on startup.
  `paddle.gd` reads bindings from here rather than owning its own keys.
- `scenes/Main.tscn` — gameplay scene. Contains both paddles, the ball, the center line/background
  visuals, and the two score labels, all as direct children of the root `Main` node.
- `scripts/main.gd` (on the `Main` root node) — owns the score. Exposes `on_goal(scorer: int)`,
  called by the ball when it exits the left/right edge of the screen. Escape returns to
  `Title.tscn`.
- `scripts/paddle.gd` (on `Paddle1`/`Paddle2`) — one script shared by both paddles, distinguished
  only by an exported `player` value (1 or 2) set per-instance in the `.tscn`, used to look up that
  player's up/down keys from the `Controls` autoload each frame. Reads
  `Input.is_physical_key_pressed` directly rather than using the project input map — there are no
  custom actions defined in `project.godot`.
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
`main.paddle2`) and `@onready var` from `main.gd`/`settings.gd` (to reach child nodes by path).
If you rename nodes in a `.tscn`, update the corresponding script's node paths.
