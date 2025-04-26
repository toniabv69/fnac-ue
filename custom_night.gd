extends Node2D

var candy_ai = 0
var cindy_ai = 0
var vinnie_ai = 0
var old_candy_ai = 0
var penguin_ai = 0
var blank_ai = 0
var chester_ai = 0
var rat_ai = 0
var cat_ai = 0
var previous_horizontal = 1
var previous_vertical = 1
var previous_down = 1
var previous_up = 1
var previous_left = 1
var previous_right = 1
var previous_start = 1

func _ready():
	$buttons/start_button.grab_focus()

func _on_back_button_up():
	get_tree().change_scene_to_file("res://main.tscn")
	
func _on_start_button_up():
	GlobalVars.candy_ai_by_night[5] = candy_ai
	GlobalVars.cindy_ai_by_night[5] = cindy_ai
	GlobalVars.vinnie_ai_by_night[5] = vinnie_ai
	GlobalVars.old_candy_ai_by_night[5] = old_candy_ai
	GlobalVars.penguin_ai_by_night[5] = penguin_ai
	GlobalVars.blank_ai_by_night[5] = blank_ai
	GlobalVars.chester_ai_by_night[5] = chester_ai
	GlobalVars.rat_ai_by_night[5] = rat_ai
	GlobalVars.cat_ai_by_night[5] = cat_ai
	get_tree().change_scene_to_file("res://pre_night.tscn")

func _process(_delta):
	$candy_ai_label.text = str(candy_ai)
	$cindy_ai_label.text = str(cindy_ai)
	$vinnie_ai_label.text = str(vinnie_ai)
	$old_candy_ai_label.text = str(old_candy_ai)
	$penguin_ai_label.text = str(penguin_ai)
	$blank_ai_label.text = str(blank_ai)
	$chester_ai_label.text = str(chester_ai)
	$rat_ai_label.text = str(rat_ai)
	$cat_ai_label.text = str(cat_ai)

func _on_candy_down_button_down():
	if candy_ai > 0:
		candy_ai -= 1

func _on_candy_up_button_down():
	if candy_ai < 20:
		candy_ai += 1

func _on_cindy_down_button_down():
	if cindy_ai > 0:
		cindy_ai -= 1

func _on_cindy_up_button_down():
	if cindy_ai < 20:
		cindy_ai += 1
		
func _on_vinnie_down_button_down():
	if vinnie_ai > 0:
		vinnie_ai -= 1

func _on_vinnie_up_button_down():
	if vinnie_ai < 20:
		vinnie_ai += 1

func _on_old_candy_down_button_down():
	if old_candy_ai > 0:
		old_candy_ai -= 1

func _on_old_candy_up_button_down():
	if old_candy_ai < 20:
		old_candy_ai += 1

func _on_penguin_down_button_down():
	if penguin_ai > 0:
		penguin_ai -= 1

func _on_penguin_up_button_down():
	if penguin_ai < 20:
		penguin_ai += 1
		
func _on_blank_down_button_down():
	if blank_ai > 0:
		blank_ai -= 1

func _on_blank_up_button_down():
	if blank_ai < 20:
		blank_ai += 1
		
func _on_chester_down_button_down():
	if chester_ai > 0:
		chester_ai -= 1

func _on_chester_up_button_down():
	if chester_ai < 20:
		chester_ai += 1
		
func _on_cat_down_button_down():
	if cat_ai > 0:
		cat_ai -= 1

func _on_cat_up_button_down():
	if cat_ai < 20:
		cat_ai += 1
		
func _on_rat_down_button_down():
	if rat_ai > 0:
		rat_ai -= 1

func _on_rat_up_button_down():
	if rat_ai < 20:
		rat_ai += 1

func _on_set_all_20_button_down():
	candy_ai = 20
	cindy_ai = 20
	chester_ai = 20
	blank_ai = 20
	vinnie_ai = 20
	cat_ai = 20
	rat_ai = 20
	old_candy_ai = 20
	penguin_ai = 20
	
func _on_set_all_0_button_down():
	candy_ai = 0
	cindy_ai = 0
	chester_ai = 0
	blank_ai = 0
	vinnie_ai = 0
	cat_ai = 0
	rat_ai = 0
	old_candy_ai = 0
	penguin_ai = 0
	
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
