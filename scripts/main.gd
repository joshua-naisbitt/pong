extends Node2D

@onready var paddle1: Node2D = $Paddle1
@onready var paddle2: Node2D = $Paddle2
@onready var ball: Node2D = $Ball
@onready var score_label1: Label = $ScoreLabel1
@onready var score_label2: Label = $ScoreLabel2

var score1 := 0
var score2 := 0

func on_goal(scorer: int) -> void:
	if scorer == 1:
		score1 += 1
	else:
		score2 += 1
	score_label1.text = str(score1)
	score_label2.text = str(score2)
	ball.launch(1 if scorer == 1 else -1)
