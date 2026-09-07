extends Node2D

@export var size: float = 20.0
@export var initial_speed: float = 300.0
@export var speed_increment: float = 20.0
@export var max_speed: float = 800.0

var velocity: Vector2 = Vector2.ZERO
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	launch(1)

func launch(direction: int) -> void:
	position = (screen_size - Vector2(size, size)) / 2.0
	var angle := randf_range(-0.3, 0.3)
	velocity = Vector2(direction, 0.0).rotated(angle) * initial_speed

func get_rect() -> Rect2:
	return Rect2(position, Vector2(size, size))

func _process(delta: float) -> void:
	position += velocity * delta

	if position.y <= 0.0:
		position.y = 0.0
		velocity.y = abs(velocity.y)
	elif position.y + size >= screen_size.y:
		position.y = screen_size.y - size
		velocity.y = -abs(velocity.y)

	var main := get_parent()
	for paddle in [main.paddle1, main.paddle2]:
		if get_rect().intersects(paddle.get_rect()):
			var from_left := velocity.x < 0.0
			var paddle_rect: Rect2 = paddle.get_rect()
			position.x = paddle_rect.position.x + (paddle_rect.size.x if from_left else -size)
			velocity.x = -velocity.x
			var new_speed: float = min(velocity.length() + speed_increment, max_speed)
			velocity = velocity.normalized() * new_speed

	if position.x + size < 0.0:
		main.on_goal(2)
	elif position.x > screen_size.x:
		main.on_goal(1)
