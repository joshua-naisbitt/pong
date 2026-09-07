extends Node2D

@onready var paddle1: Node2D = $Paddle1
@onready var paddle2: Node2D = $Paddle2
@onready var ball: Node2D = $Ball
@onready var score_label1: Label = $ScoreLabel1
@onready var score_label2: Label = $ScoreLabel2
@onready var score_sound: AudioStreamPlayer = $ScoreSound
@onready var win_label: Label = $WinLabel
@onready var win_subtitle_label: Label = $WinSubtitleLabel
@onready var background: ColorRect = $Background

const WIN_SCORE := 11

var score1 := 0
var score2 := 0
var game_over := false

func _ready() -> void:
	background.color = Controls.background_color
	score_label1.add_theme_color_override("font_color", Controls.get_effective_text_color())
	score_label2.add_theme_color_override("font_color", Controls.get_effective_text_color())
	win_label.add_theme_color_override("font_color", Controls.get_effective_text_color())

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/Title.tscn")

func on_goal(scorer: int) -> void:
	if game_over:
		return

	if scorer == 1:
		score1 += 1
	else:
		score2 += 1
	score_label1.text = str(score1)
	score_label2.text = str(score2)
	score_sound.play()

	if score1 >= WIN_SCORE or score2 >= WIN_SCORE:
		game_over = true
		win_label.text = "Player %d Wins!" % scorer
		win_label.show()
		win_subtitle_label.show()
		ball.stop()
		ball.hide()
	else:
		ball.launch(1 if scorer == 1 else -1)
