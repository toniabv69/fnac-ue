extends Control

@onready
var continue_button = get_node("continue_button")

func _init():
	if not GlobalVars.loaded:
		if FileAccess.file_exists("user://save.txt"):
			var file = FileAccess.open("user://save.txt", FileAccess.READ)
			var result = int(file.get_as_text())
			GlobalVars.night = int(result / 10)
			GlobalVars.custom_night_unlocked = result % 10
			file.close()
		else:
			GlobalVars.night = 1
		GlobalVars.loaded = true
	if GlobalVars.night > 5:
		GlobalVars.night = GlobalVars.old_night
	

func _ready():
	$new_game_button.grab_focus()
	continue_button.text = "Continue (Night " + str(GlobalVars.night) + ")"
	if GlobalVars.custom_night_unlocked == 1:
		$custom_night_button.disabled = false
	else:
		$custom_night_button.disabled = true

func _on_quit_button_up():
	var file = FileAccess.open("user://save.txt", FileAccess.WRITE)
	file.store_string(str(GlobalVars.night) + str(GlobalVars.custom_night_unlocked))
	file.close()
	get_tree().quit()


func _on_new_game_button_up():
	GlobalVars.night = 1
	get_tree().change_scene_to_file("res://pre_night.tscn")
	

func _on_continue_button_up():
	get_tree().change_scene_to_file("res://pre_night.tscn")


func _on_custom_night_button_up():
	GlobalVars.old_night = GlobalVars.night
	GlobalVars.night = 6
	get_tree().change_scene_to_file("res://custom_night.tscn")
