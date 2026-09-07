extends Control

const DIFFICULTIES := ["easy", "medium", "hard"]

@onready var difficulty_option: OptionButton = $CenterContainer/VBoxContainer/DifficultyOption

func _ready() -> void:
	difficulty_option.select(DIFFICULTIES.find(Controls.ai_difficulty))

func _on_pvp_pressed() -> void:
	start_game(false, false)

func _on_pva_pressed() -> void:
	start_game(false, true)

func _on_ava_pressed() -> void:
	start_game(true, true)

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_difficulty_option_item_selected(index: int) -> void:
	Controls.set_ai_difficulty(DIFFICULTIES[index])

func start_game(p1_ai: bool, p2_ai: bool) -> void:
	Controls.set_game_mode(p1_ai, p2_ai)
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
