extends Control

const PaddleScript = preload("res://scripts/paddle.gd")
const ControlsScript = preload("res://scripts/controls.gd")

const PREVIEW_BOX_HEIGHT := PaddleScript.DEFAULT_HEIGHT * ControlsScript.MAX_PADDLE_SCALE + 20.0
const PREVIEW_BALL_SPEED := 110.0

@onready var p1_up_button: Button = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/ControlsRow/Player1Column/P1UpRow/RebindButton
@onready var p1_down_button: Button = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/ControlsRow/Player1Column/P1DownRow/RebindButton
@onready var p2_up_button: Button = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/ControlsRow/Player2Column/P2UpRow/RebindButton
@onready var p2_down_button: Button = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/ControlsRow/Player2Column/P2DownRow/RebindButton

@onready var paddle_size_slider: HSlider = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/PaddleSizeRow/Slider
@onready var paddle_size_value_label: Label = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/PaddleSizeRow/ValueLabel
@onready var paddle_speed_slider: HSlider = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/PaddleSpeedRow/Slider
@onready var paddle_speed_value_label: Label = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/PaddleSpeedRow/ValueLabel
@onready var win_score_row: HBoxContainer = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/WinScoreRow
@onready var win_score_slider: HSlider = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/WinScoreRow/Slider
@onready var win_score_value_label: Label = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/WinScoreRow/ValueLabel
@onready var endless_toggle: CheckButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/EndlessRow/CheckButton
@onready var resolution_option: OptionButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/ResolutionRow/OptionButton

@onready var color_mode_toggle: CheckButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/ColorModeRow/CheckButton
@onready var game_color_row: HBoxContainer = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/GameColorRow
@onready var game_color_button: ColorPickerButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/GameColorRow/ColorPickerButton
@onready var paddle1_color_row: HBoxContainer = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/Paddle1ColorRow
@onready var paddle1_color_button: ColorPickerButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/Paddle1ColorRow/ColorPickerButton
@onready var paddle2_color_row: HBoxContainer = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/Paddle2ColorRow
@onready var paddle2_color_button: ColorPickerButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/Paddle2ColorRow/ColorPickerButton
@onready var ball_color_row: HBoxContainer = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/BallColorRow
@onready var ball_color_button: ColorPickerButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/BallColorRow/ColorPickerButton
@onready var text_color_row: HBoxContainer = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/TextColorRow
@onready var text_color_button: ColorPickerButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/TextColorRow/ColorPickerButton
@onready var background_color_button: ColorPickerButton = $ScrollContainer/ContentMargin/CenterContainer/Layout/VBoxContainer/OptionsMargin/OptionsList/BackgroundColorRow/ColorPickerButton

@onready var preview_box: ColorRect = $ScrollContainer/ContentMargin/CenterContainer/Layout/PreviewColumn/PreviewBox
@onready var preview_paddle: ColorRect = $ScrollContainer/ContentMargin/CenterContainer/Layout/PreviewColumn/PreviewBox/PreviewPaddle
@onready var preview_paddle2: ColorRect = $ScrollContainer/ContentMargin/CenterContainer/Layout/PreviewColumn/PreviewBox/PreviewPaddle2
@onready var preview_ball: ColorRect = $ScrollContainer/ContentMargin/CenterContainer/Layout/PreviewColumn/PreviewBox/PreviewBall
@onready var preview_score_label: Label = $ScrollContainer/ContentMargin/CenterContainer/Layout/PreviewColumn/PreviewBox/PreviewScoreLabel

var listening_player := 0
var listening_is_up := false
var listening_button: Button = null
var preview_direction := 1.0
var preview_direction2 := -1.0
var preview_ball_velocity := Vector2(1, 1).normalized() * PREVIEW_BALL_SPEED

func _ready() -> void:
	for i in Controls.get_available_resolution_indices():
		var resolution: Vector2i = ControlsScript.RESOLUTIONS[i]
		resolution_option.add_item("%dx%d" % [resolution.x, resolution.y])
		resolution_option.set_item_metadata(resolution_option.item_count - 1, i)
	_refresh_from_controls()

func _refresh_from_controls() -> void:
	_refresh_labels()
	paddle_size_slider.value = Controls.paddle_size_scale
	paddle_speed_slider.value = Controls.paddle_speed_scale
	win_score_slider.value = Controls.win_score
	win_score_value_label.text = str(Controls.win_score)
	endless_toggle.button_pressed = Controls.endless_mode
	_update_win_score_state()
	_update_preview_size()
	for i in resolution_option.item_count:
		if resolution_option.get_item_metadata(i) == Controls.resolution_index:
			resolution_option.selected = i
			break
	color_mode_toggle.button_pressed = Controls.advanced_colors
	game_color_button.color = Controls.paddle1_color
	paddle1_color_button.color = Controls.paddle1_color
	paddle2_color_button.color = Controls.paddle2_color
	ball_color_button.color = Controls.ball_color
	text_color_button.color = Controls.text_color
	background_color_button.color = Controls.background_color
	preview_paddle.color = Controls.get_effective_paddle_color(1)
	preview_paddle2.color = Controls.get_effective_paddle_color(2)
	preview_ball.color = Controls.get_effective_ball_color()
	preview_score_label.add_theme_color_override("font_color", Controls.get_effective_text_color())
	preview_box.color = Controls.background_color
	_update_color_mode_visibility()

func _process(delta: float) -> void:
	var speed := PaddleScript.DEFAULT_SPEED * paddle_speed_slider.value
	preview_paddle.position.y += preview_direction * speed * delta
	var max_y: float = max(0.0, PREVIEW_BOX_HEIGHT - preview_paddle.size.y)
	if preview_paddle.position.y <= 0.0:
		preview_paddle.position.y = 0.0
		preview_direction = 1.0
	elif preview_paddle.position.y >= max_y:
		preview_paddle.position.y = max_y
		preview_direction = -1.0

	preview_paddle2.position.y += preview_direction2 * speed * delta
	var max_y2: float = max(0.0, PREVIEW_BOX_HEIGHT - preview_paddle2.size.y)
	if preview_paddle2.position.y <= 0.0:
		preview_paddle2.position.y = 0.0
		preview_direction2 = 1.0
	elif preview_paddle2.position.y >= max_y2:
		preview_paddle2.position.y = max_y2
		preview_direction2 = -1.0

	preview_ball.position += preview_ball_velocity * delta
	var ball_min_x := preview_paddle.position.x + preview_paddle.size.x
	var ball_max_x := preview_paddle2.position.x - preview_ball.size.x
	var ball_max_y := PREVIEW_BOX_HEIGHT - preview_ball.size.y
	if preview_ball.position.x <= ball_min_x:
		preview_ball.position.x = ball_min_x
		preview_ball_velocity.x = abs(preview_ball_velocity.x)
	elif preview_ball.position.x >= ball_max_x:
		preview_ball.position.x = ball_max_x
		preview_ball_velocity.x = -abs(preview_ball_velocity.x)
	if preview_ball.position.y <= 0.0:
		preview_ball.position.y = 0.0
		preview_ball_velocity.y = abs(preview_ball_velocity.y)
	elif preview_ball.position.y >= ball_max_y:
		preview_ball.position.y = ball_max_y
		preview_ball_velocity.y = -abs(preview_ball_velocity.y)

func _update_preview_size() -> void:
	var height := PaddleScript.DEFAULT_HEIGHT * Controls.paddle_size_scale
	preview_paddle.size.y = height
	preview_paddle.position.y = clamp(preview_paddle.position.y, 0.0, max(0.0, PREVIEW_BOX_HEIGHT - height))
	preview_paddle2.size.y = height
	preview_paddle2.position.y = clamp(preview_paddle2.position.y, 0.0, max(0.0, PREVIEW_BOX_HEIGHT - height))

func _update_win_score_state() -> void:
	var endless := Controls.endless_mode
	win_score_slider.editable = not endless
	win_score_row.modulate = Color(1, 1, 1, 0.4) if endless else Color(1, 1, 1, 1)

func _update_color_mode_visibility() -> void:
	var advanced := Controls.advanced_colors
	game_color_row.visible = not advanced
	paddle1_color_row.visible = advanced
	paddle2_color_row.visible = advanced
	ball_color_row.visible = advanced
	text_color_row.visible = advanced

func _refresh_labels() -> void:
	p1_up_button.text = OS.get_keycode_string(Controls.p1_up)
	p1_down_button.text = OS.get_keycode_string(Controls.p1_down)
	p2_up_button.text = OS.get_keycode_string(Controls.p2_up)
	p2_down_button.text = OS.get_keycode_string(Controls.p2_down)

func _start_listening(player: int, is_up: bool, button: Button) -> void:
	listening_player = player
	listening_is_up = is_up
	listening_button = button
	button.text = "Press a key..."

func _on_p1_up_rebind_pressed() -> void:
	_start_listening(1, true, p1_up_button)

func _on_p1_down_rebind_pressed() -> void:
	_start_listening(1, false, p1_down_button)

func _on_p2_up_rebind_pressed() -> void:
	_start_listening(2, true, p2_up_button)

func _on_p2_down_rebind_pressed() -> void:
	_start_listening(2, false, p2_down_button)

func _unhandled_key_input(event: InputEvent) -> void:
	if listening_button == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		Controls.set_key(listening_player, listening_is_up, event.physical_keycode)
		listening_button = null
		_refresh_labels()
		get_viewport().set_input_as_handled()

func _on_paddle_size_slider_value_changed(value: float) -> void:
	Controls.set_paddle_size_scale(value)
	paddle_size_value_label.text = "%.2fx" % value
	_update_preview_size()

func _on_paddle_speed_slider_value_changed(value: float) -> void:
	Controls.set_paddle_speed_scale(value)
	paddle_speed_value_label.text = "%.2fx" % value

func _on_win_score_slider_value_changed(value: float) -> void:
	Controls.set_win_score(int(value))
	win_score_value_label.text = str(Controls.win_score)

func _on_endless_check_button_toggled(pressed: bool) -> void:
	Controls.set_endless_mode(pressed)
	_update_win_score_state()

func _on_resolution_option_button_item_selected(index: int) -> void:
	Controls.set_resolution_index(resolution_option.get_item_metadata(index))

func _on_color_mode_check_button_toggled(pressed: bool) -> void:
	Controls.set_advanced_colors(pressed)
	if not pressed:
		_on_game_color_changed(game_color_button.color)
	_update_color_mode_visibility()

func _on_game_color_changed(color: Color) -> void:
	Controls.set_game_color(color)
	paddle1_color_button.color = color
	paddle2_color_button.color = color
	ball_color_button.color = color
	text_color_button.color = color
	preview_paddle.color = color
	preview_paddle2.color = color
	preview_ball.color = color
	preview_score_label.add_theme_color_override("font_color", color)

func _on_paddle1_color_changed(color: Color) -> void:
	Controls.set_paddle1_color(color)
	preview_paddle.color = color

func _on_paddle2_color_changed(color: Color) -> void:
	Controls.set_paddle2_color(color)
	preview_paddle2.color = color

func _on_ball_color_changed(color: Color) -> void:
	Controls.set_ball_color(color)
	preview_ball.color = color

func _on_text_color_changed(color: Color) -> void:
	Controls.set_text_color(color)
	preview_score_label.add_theme_color_override("font_color", color)

func _on_background_color_changed(color: Color) -> void:
	Controls.set_background_color(color)
	preview_box.color = color

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Title.tscn")

func _on_reset_pressed() -> void:
	Controls.reset_to_defaults()
	_refresh_from_controls()
