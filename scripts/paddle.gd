extends Node2D

const DEFAULT_HEIGHT := 100.0
const DEFAULT_SPEED := 400.0

@export var width: float = 20.0
@export var base_height: float = DEFAULT_HEIGHT
@export var base_speed: float = DEFAULT_SPEED
@export var player: int = 1

@onready var color_rect: ColorRect = $ColorRect

var height: float
var speed: float
var screen_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready() -> void:
	height = base_height * Controls.paddle_size_scale
	speed = base_speed * Controls.paddle_speed_scale
	color_rect.offset_bottom = height
	color_rect.color = Controls.get_effective_paddle_color(player)
	position.y = clamp(position.y, 0.0, screen_height - height)

func _process(delta: float) -> void:
	var direction := 0.0
	if Input.is_physical_key_pressed(Controls.get_up_key(player)):
		direction -= 1.0
	if Input.is_physical_key_pressed(Controls.get_down_key(player)):
		direction += 1.0

	position.y += direction * speed * delta
	position.y = clamp(position.y, 0.0, screen_height - height)

func get_rect() -> Rect2:
	return Rect2(global_position, Vector2(width, height))
