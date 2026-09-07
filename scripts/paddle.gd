extends Node2D

@export var width: float = 20.0
@export var height: float = 100.0
@export var speed: float = 400.0
@export var up_key: Key = KEY_W
@export var down_key: Key = KEY_S

var screen_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")

func _process(delta: float) -> void:
	var direction := 0.0
	if Input.is_physical_key_pressed(up_key):
		direction -= 1.0
	if Input.is_physical_key_pressed(down_key):
		direction += 1.0

	position.y += direction * speed * delta
	position.y = clamp(position.y, 0.0, screen_height - height)

func get_rect() -> Rect2:
	return Rect2(global_position, Vector2(width, height))
