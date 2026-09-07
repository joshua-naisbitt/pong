extends Node2D

const DEFAULT_HEIGHT := 100.0
const DEFAULT_SPEED := 400.0

const AI_ERROR_UPDATE_INTERVAL := 0.4
const AI_DEAD_ZONE := 4.0
const AI_SETTINGS := {
	"easy": {"speed_scale": 0.5, "error": 40.0},
	"medium": {"speed_scale": 0.75, "error": 15.0},
	"hard": {"speed_scale": 1.0, "error": 0.0},
}

@export var width: float = 20.0
@export var base_height: float = DEFAULT_HEIGHT
@export var base_speed: float = DEFAULT_SPEED
@export var player: int = 1

@onready var color_rect: ColorRect = $ColorRect

var height: float
var speed: float
var screen_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

var ai_error_offset: float = 0.0
var ai_error_timer: float = 0.0

func _ready() -> void:
	height = base_height * Controls.paddle_size_scale
	speed = base_speed * Controls.paddle_speed_scale
	color_rect.offset_bottom = height
	color_rect.color = Controls.get_effective_paddle_color(player)
	position.y = clamp(position.y, 0.0, screen_height - height)

func _process(delta: float) -> void:
	var direction := 0.0
	var move_speed := speed

	if is_ai_controlled():
		var settings: Dictionary = AI_SETTINGS[Controls.ai_difficulty]
		direction = get_ai_direction(delta, settings)
		move_speed *= settings.speed_scale
	else:
		if Input.is_physical_key_pressed(Controls.get_up_key(player)):
			direction -= 1.0
		if Input.is_physical_key_pressed(Controls.get_down_key(player)):
			direction += 1.0

	position.y += direction * move_speed * delta
	position.y = clamp(position.y, 0.0, screen_height - height)

func is_ai_controlled() -> bool:
	return Controls.p1_is_ai if player == 1 else Controls.p2_is_ai

func get_ai_direction(delta: float, settings: Dictionary) -> float:
	var ball: Node2D = get_parent().ball

	ai_error_timer -= delta
	if ai_error_timer <= 0.0:
		ai_error_timer = AI_ERROR_UPDATE_INTERVAL
		ai_error_offset = randf_range(-settings.error, settings.error)

	var target_y: float = ball.position.y + ball.size / 2.0 + ai_error_offset
	var paddle_center_y := position.y + height / 2.0

	if target_y < paddle_center_y - AI_DEAD_ZONE:
		return -1.0
	elif target_y > paddle_center_y + AI_DEAD_ZONE:
		return 1.0
	return 0.0

func get_rect() -> Rect2:
	return Rect2(global_position, Vector2(width, height))
