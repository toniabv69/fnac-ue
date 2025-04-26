extends Control

@onready
var continue_button = get_node("continue_button")
var previous_start = 1
var previous_horizontal = 1
var previous_vertical = 1
var previous_down = 1
var previous_up = 1
var previous_left = 1
var previous_right = 1

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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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

func _on_arduino_data_recieved(myString: String) -> void:
	var old_result = myString.split(" ")
	var result = []
	result.resize(len(old_result))
	for i in range(len(old_result)):
		result[i] = round(float(old_result[i]))
	var current_horizontal = float(result[1])
	var current_vertical = float(result[0])
	var right_button_pressed = int(result[3])
	var left_button_pressed = int(result[4])
	var down_button_pressed = int(result[5])
	var up_button_pressed = int(result[6])
	var start_button_pressed = int(result[7])
	if (current_horizontal > 0.3 or current_horizontal < -0.3) and previous_horizontal == 0:
		var event = InputEventKey.new()
		event.keycode = (KEY_RIGHT if current_horizontal > 0 else KEY_LEFT)
		event.pressed = true
		Input.parse_input_event(event)
		
		event = InputEventKey.new()
		event.keycode = (KEY_RIGHT if current_horizontal > 0 else KEY_LEFT)
		event.pressed = false
		Input.parse_input_event(event)
	previous_horizontal = current_horizontal
	if (current_vertical > 0.3 or current_vertical < -0.3) and previous_vertical == 0:
		var event = InputEventKey.new()
		event.keycode = (KEY_UP if current_vertical > 0 else KEY_DOWN)
		event.pressed = true
		Input.parse_input_event(event)
		
		event = InputEventKey.new()
		event.keycode = (KEY_UP if current_vertical > 0 else KEY_DOWN)
		event.pressed = false
		Input.parse_input_event(event)
	previous_vertical = current_vertical
	if down_button_pressed and previous_down == 0:
		var event = InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = true
		Input.parse_input_event(event)
		
		event = InputEventKey.new()
		event.keycode = KEY_ENTER
		event.pressed = false
		Input.parse_input_event(event)
	previous_down = down_button_pressed
