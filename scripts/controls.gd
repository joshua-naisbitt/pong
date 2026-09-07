extends Node

const SAVE_PATH := "user://controls.cfg"

const MIN_PADDLE_SCALE := 0.5
const MAX_PADDLE_SCALE := 2.0

const MIN_WIN_SCORE := 1
const MAX_WIN_SCORE := 21

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(800, 600),
	Vector2i(1024, 768),
	Vector2i(1280, 960),
	Vector2i(1600, 1200),
]

var p1_up: Key = KEY_W
var p1_down: Key = KEY_S
var p2_up: Key = KEY_UP
var p2_down: Key = KEY_DOWN

var p1_is_ai: bool = false
var p2_is_ai: bool = false
var ai_difficulty: String = "medium"

var paddle_size_scale: float = 1.0
var paddle_speed_scale: float = 1.0
var resolution_index: int = 0

var win_score: int = 11
var endless_mode: bool = false

var paddle1_color: Color = Color(1, 1, 1, 1)
var paddle2_color: Color = Color(1, 1, 1, 1)
var ball_color: Color = Color(1, 1, 1, 1)
var background_color: Color = Color(0.05, 0.05, 0.08, 1)
var text_color: Color = Color(1, 1, 1, 1)
var advanced_colors: bool = false

func _ready() -> void:
	load_settings()
	apply_resolution()

func get_up_key(player: int) -> Key:
	return p1_up if player == 1 else p2_up

func get_down_key(player: int) -> Key:
	return p1_down if player == 1 else p2_down

func set_game_mode(p1_ai: bool, p2_ai: bool) -> void:
	p1_is_ai = p1_ai
	p2_is_ai = p2_ai

func set_ai_difficulty(value: String) -> void:
	ai_difficulty = value
	save_settings()

func set_key(player: int, is_up: bool, key: Key) -> void:
	if player == 1:
		if is_up:
			p1_up = key
		else:
			p1_down = key
	else:
		if is_up:
			p2_up = key
		else:
			p2_down = key
	save_settings()

func set_paddle_size_scale(value: float) -> void:
	paddle_size_scale = clamp(value, MIN_PADDLE_SCALE, MAX_PADDLE_SCALE)
	save_settings()

func set_paddle_speed_scale(value: float) -> void:
	paddle_speed_scale = clamp(value, MIN_PADDLE_SCALE, MAX_PADDLE_SCALE)
	save_settings()

func set_win_score(value: int) -> void:
	win_score = clamp(value, MIN_WIN_SCORE, MAX_WIN_SCORE)
	save_settings()

func set_endless_mode(value: bool) -> void:
	endless_mode = value
	save_settings()

func set_resolution_index(index: int) -> void:
	resolution_index = clamp(index, 0, RESOLUTIONS.size() - 1)
	apply_resolution()
	save_settings()

func apply_resolution() -> void:
	get_window().size = RESOLUTIONS[resolution_index]

func resolution_fits(resolution: Vector2i) -> bool:
	var usable := DisplayServer.screen_get_usable_rect().size
	return resolution.x <= usable.x and resolution.y <= usable.y

func get_available_resolution_indices() -> Array[int]:
	var indices: Array[int] = []
	for i in RESOLUTIONS.size():
		if resolution_fits(RESOLUTIONS[i]):
			indices.append(i)
	if indices.is_empty():
		indices.append(0)
	return indices

func set_paddle1_color(color: Color) -> void:
	paddle1_color = color
	save_settings()

func set_paddle2_color(color: Color) -> void:
	paddle2_color = color
	save_settings()

func set_ball_color(color: Color) -> void:
	ball_color = color
	save_settings()

func set_background_color(color: Color) -> void:
	background_color = color
	save_settings()

func set_text_color(color: Color) -> void:
	text_color = color
	save_settings()

func set_game_color(color: Color) -> void:
	paddle1_color = color
	paddle2_color = color
	ball_color = color
	text_color = color
	save_settings()

func set_advanced_colors(value: bool) -> void:
	advanced_colors = value
	save_settings()

func get_effective_paddle_color(player: int) -> Color:
	if not advanced_colors:
		return paddle1_color
	return paddle1_color if player == 1 else paddle2_color

func get_effective_ball_color() -> Color:
	return ball_color if advanced_colors else paddle1_color

func get_effective_text_color() -> Color:
	return text_color if advanced_colors else paddle1_color

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "p1_up", p1_up)
	config.set_value("controls", "p1_down", p1_down)
	config.set_value("controls", "p2_up", p2_up)
	config.set_value("controls", "p2_down", p2_down)
	config.set_value("gameplay", "paddle_size_scale", paddle_size_scale)
	config.set_value("gameplay", "paddle_speed_scale", paddle_speed_scale)
	config.set_value("gameplay", "win_score", win_score)
	config.set_value("gameplay", "endless_mode", endless_mode)
	config.set_value("gameplay", "ai_difficulty", ai_difficulty)
	config.set_value("display", "resolution_index", resolution_index)
	config.set_value("colors", "paddle1_color", paddle1_color)
	config.set_value("colors", "paddle2_color", paddle2_color)
	config.set_value("colors", "ball_color", ball_color)
	config.set_value("colors", "background_color", background_color)
	config.set_value("colors", "text_color", text_color)
	config.set_value("colors", "advanced_colors", advanced_colors)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	p1_up = config.get_value("controls", "p1_up", p1_up)
	p1_down = config.get_value("controls", "p1_down", p1_down)
	p2_up = config.get_value("controls", "p2_up", p2_up)
	p2_down = config.get_value("controls", "p2_down", p2_down)
	paddle_size_scale = config.get_value("gameplay", "paddle_size_scale", paddle_size_scale)
	paddle_speed_scale = config.get_value("gameplay", "paddle_speed_scale", paddle_speed_scale)
	win_score = clamp(config.get_value("gameplay", "win_score", win_score), MIN_WIN_SCORE, MAX_WIN_SCORE)
	endless_mode = config.get_value("gameplay", "endless_mode", endless_mode)
	ai_difficulty = config.get_value("gameplay", "ai_difficulty", ai_difficulty)
	resolution_index = clamp(config.get_value("display", "resolution_index", resolution_index), 0, RESOLUTIONS.size() - 1)
	if not resolution_fits(RESOLUTIONS[resolution_index]):
		resolution_index = get_available_resolution_indices().back()
	paddle1_color = config.get_value("colors", "paddle1_color", paddle1_color)
	paddle2_color = config.get_value("colors", "paddle2_color", paddle2_color)
	ball_color = config.get_value("colors", "ball_color", ball_color)
	background_color = config.get_value("colors", "background_color", background_color)
	text_color = config.get_value("colors", "text_color", text_color)
	advanced_colors = config.get_value("colors", "advanced_colors", advanced_colors)
