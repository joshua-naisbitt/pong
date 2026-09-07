extends Node2D

@export var size: float = 20.0
@export var initial_speed: float = 450.0
@export var speed_increment: float = 20.0
@export var max_speed: float = 800.0
@export var max_bounce_angle_deg: float = 60.0

@onready var hit_sound: AudioStreamPlayer = $HitSound
@onready var color_rect: ColorRect = $ColorRect

var velocity: Vector2 = Vector2.ZERO
var stopped: bool = false
var screen_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

func _ready() -> void:
	color_rect.color = Controls.get_effective_ball_color()
	launch(1)

func launch(direction: int) -> void:
	stopped = false
	position = (screen_size - Vector2(size, size)) / 2.0
	var angle := randf_range(-0.3, 0.3)
	velocity = Vector2(direction, 0.0).rotated(angle) * initial_speed

func stop() -> void:
	stopped = true
	velocity = Vector2.ZERO
	position = (screen_size - Vector2(size, size)) / 2.0

func get_rect() -> Rect2:
	return Rect2(position, Vector2(size, size))

func _process(delta: float) -> void:
	if stopped:
		return

	position += velocity * delta

	if position.y <= 0.0:
		position.y = 0.0
		velocity.y = abs(velocity.y)
	elif position.y + size >= screen_size.y:
		position.y = screen_size.y - size
		velocity.y = -abs(velocity.y)

	var main := get_parent()
	for paddle in [main.paddle1, main.paddle2]:
		var paddle_rect: Rect2 = paddle.get_rect()
		if get_rect().intersects(paddle_rect):
			var from_left := velocity.x < 0.0
			position.x = paddle_rect.position.x + (paddle_rect.size.x if from_left else -size)
			hit_sound.play()

			var ball_center_y := position.y + size / 2.0
			var paddle_center_y := paddle_rect.position.y + paddle_rect.size.y / 2.0
			var offset := (ball_center_y - paddle_center_y) / (paddle_rect.size.y / 2.0)
			offset = clamp(offset, -1.0, 1.0)
			var angle := offset * deg_to_rad(max_bounce_angle_deg)

			var new_speed: float = min(velocity.length() + speed_increment, max_speed)
			var direction_x := 1.0 if from_left else -1.0
			velocity = Vector2(cos(angle) * direction_x, sin(angle)) * new_speed

	if position.x + size < 0.0:
		main.on_goal(2)
	elif position.x > screen_size.x:
		main.on_goal(1)
