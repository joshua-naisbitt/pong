extends Node

func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="):
			_capture_screenshot_and_quit(arg.split("=")[1])

func _capture_screenshot_and_quit(path: String) -> void:
	# Wait a couple frames so the current scene has actually rendered before capturing.
	await get_tree().process_frame
	await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
