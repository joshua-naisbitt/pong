extends Node2D

@onready var paddle1: Node2D = $Paddle1
@onready var paddle2: Node2D = $Paddle2
@onready var ball: Node2D = $Ball
@onready var score_label1: Label = $ScoreLabel1
@onready var score_label2: Label = $ScoreLabel2
@onready var score_sound: AudioStreamPlayer = $ScoreSound

var score1 := 0
var score2 := 0

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_capture_screenshot_and_quit(arg.split("=")[1])

func _capture_screenshot_and_quit(path: String) -> void:
	# Wait a couple frames so the scene has actually rendered before capturing.
	await get_tree().process_frame
	await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()

func on_goal(scorer: int) -> void:
	if scorer == 1:
		score1 += 1
	else:
		score2 += 1
	score_label1.text = str(score1)
	score_label2.text = str(score2)
	score_sound.play()
	ball.launch(1 if scorer == 1 else -1)
