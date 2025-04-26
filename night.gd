extends Node2D

var previous_start = 1
var previous_horizontal = 1
var previous_vertical = 1
var previous_down = 1
var previous_up = 1
var previous_left = 1
var previous_right = 1
var cam_button_enable = true
var cams_on = false
var controller_wind = false
@onready
var cams := $cam_map/cam_buttons.get_children()
var power = 100
var usage = 2
var timer = 0
var playing_cam_animation = false
var playing_ldoor_animation = false
var playing_rdoor_animation = false
var playing_vdoor_animation = false
@onready
var audio_playing = -1
@onready
var selected_cam = cams[GlobalVars.states.CAM_1A]
var left_door = false
var right_door = false
var vent_door = false
var ldoor_disabled = false
var rdoor_disabled = false
var music_box = 1200
var wind = false
var vinnie_state = 0
var vinnie_move = true
var rat_run = false
var jumpscare = false
var candy = Animatronic.new(GlobalVars.states.CAM_1A, GlobalVars.states.CAM_1B, GlobalVars.candy_timer, GlobalVars.candy_attack_timer, GlobalVars.candy_ai_by_night[GlobalVars.night - 1], GlobalVars.candy_probs)
var cindy = Animatronic.new(GlobalVars.states.CAM_1A, GlobalVars.states.CAM_1B, GlobalVars.cindy_timer, GlobalVars.cindy_attack_timer, GlobalVars.cindy_ai_by_night[GlobalVars.night - 1], GlobalVars.cindy_probs)
var vinnie = Animatronic.new(GlobalVars.states.CAM_6, GlobalVars.states.CAM_6, GlobalVars.vinnie_timer, GlobalVars.vinnie_attack_timer, GlobalVars.vinnie_ai_by_night[GlobalVars.night - 1], GlobalVars.vinnie_probs)
var old_candy = Animatronic.new(GlobalVars.states.CAM_10, GlobalVars.states.CAM_10, GlobalVars.old_candy_timer, GlobalVars.old_candy_attack_timer, GlobalVars.old_candy_ai_by_night[GlobalVars.night - 1], GlobalVars.old_candy_probs)
var penguin = Animatronic.new(GlobalVars.states.CAM_10, GlobalVars.states.CAM_10, GlobalVars.penguin_timer, GlobalVars.penguin_attack_timer, GlobalVars.penguin_ai_by_night[GlobalVars.night - 1], GlobalVars.penguin_probs)
var blank = Animatronic.new(GlobalVars.states.CAM_7, GlobalVars.states.CAM_7, GlobalVars.blank_timer, GlobalVars.blank_attack_timer, GlobalVars.blank_ai_by_night[GlobalVars.night - 1], GlobalVars.blank_probs)
var chester = Animatronic.new(GlobalVars.states.CAM_2, GlobalVars.states.CAM_2, GlobalVars.chester_timer, GlobalVars.chester_attack_timer, GlobalVars.chester_ai_by_night[GlobalVars.night - 1], GlobalVars.chester_probs)
var cat = Animatronic.new(GlobalVars.states.CAM_10, GlobalVars.states.CAM_10, GlobalVars.cat_timer, GlobalVars.cat_attack_timer, GlobalVars.cat_ai_by_night[GlobalVars.night - 1], GlobalVars.cat_probs)
var rat = Animatronic.new(GlobalVars.states.CAM_10, GlobalVars.states.CAM_10, GlobalVars.rat_timer, GlobalVars.rat_attack_timer, GlobalVars.rat_ai_by_night[GlobalVars.night - 1], GlobalVars.rat_probs)

class Animatronic:
	var state
	var retreat_state
	var move_timer
	var attack_timer
	var ai_level
	var probabilities
	var attempt_count
	
	func _init(_state, _retreat_state, _timer, _attack_timer, _ai_level, _probabilities):
		state = _state
		retreat_state = _retreat_state
		move_timer = _timer
		attack_timer = _attack_timer
		ai_level = _ai_level
		probabilities = _probabilities
		attempt_count = 0
		
	func move(left_door, right_door, vent_door):
		if state == GlobalVars.states.OFFICE:
			return -1
		if state == GlobalVars.states.LEFT_DOOR:
			if not left_door:
				state = GlobalVars.states.OFFICE
				return GlobalVars.states.LEFT_DOOR
			else:
				state = retreat_state
				return state
		elif state == GlobalVars.states.RIGHT_DOOR:
			if not right_door:
				state = GlobalVars.states.OFFICE
				return GlobalVars.states.RIGHT_DOOR
			else:
				state = retreat_state
				return state
		elif state == GlobalVars.states.VENT:
			if not vent_door:
				state = GlobalVars.states.OFFICE
				return GlobalVars.states.VENT
			else:
				state = retreat_state
				return state
		else:
			var chance = GlobalVars.rng.randi_range(1, 100)
			for probability in probabilities[state].probabilities:
				if chance <= probability.chance:
					state = probability.to_go
					return state
				
	
	func attempt_move():
		var chance = GlobalVars.rng.randi_range(1, 25)
		if chance <= ai_level:
			return true
		else:
			return false
		

func open_cams():
	if not playing_cam_animation:
		cams_on = true
		print("cams opened")
		$audio_ambience_player.volume_db = -45.71
		$audio_cams_player.stream = load("res://assets/audio/cams_on.mp3")
		$audio_cams_player.play()
		playing_cam_animation = true
		await get_tree().create_timer(0.10).timeout
		$office_buttons/left_door_button.hide()
		$office_buttons/right_door_button.hide()
		await get_tree().create_timer(0.10).timeout
		$office_buttons/vent_door_button.hide()
		await get_tree().create_timer(0.05).timeout
		playing_cam_animation = false
		$office_background.visible = false
		$cam_map.visible = true
		usage += 1
		selected_cam.grab_focus()
		if selected_cam == cams[GlobalVars.states.CAM_7]:
			$audio_music_box_player.volume_db = -14
		if candy.state == GlobalVars.states.OFFICE or cindy.state == GlobalVars.states.OFFICE:
			$cam_jumpscare_timer.start(12)
		if vinnie_move == true or not $vinnie_advance_timer.is_stopped():
			if selected_cam == cams[GlobalVars.states.CAM_6]:
				vinnie_move = false
				$vinnie_advance_timer.stop()
		if not $rat_run_timer.is_stopped():
			if rat.state not in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
				if selected_cam == cams[rat.state]:
					$rat_run_timer.stop()

func close_cams():
		if not playing_cam_animation:
			cams_on = false
			print("cams closed")
			$audio_ambience_player.volume_db = -25.71
			$audio_cams_player.stream = load("res://assets/audio/cams_off.mp3")
			$audio_cams_player.play()
			$cam_map.visible = false
			$audio_music_box_player.volume_db = -54
			usage -= 1
			playing_cam_animation = true
			$office_background.visible = true			
			await get_tree().create_timer(0.05).timeout
			if candy.state == GlobalVars.states.OFFICE or cindy.state == GlobalVars.states.OFFICE:
				print("boo")
				game_over(false)
			$office_buttons/vent_door_button.show()
			await get_tree().create_timer(0.10).timeout
			$office_buttons/left_door_button.show()
			$office_buttons/right_door_button.show()
			await get_tree().create_timer(0.10).timeout
			playing_cam_animation = false
			if $vinnie_advance_timer.is_stopped():
				$vinnie_advance_timer.start(12 - vinnie.ai_level * 0.5 + (GlobalVars.rng.randi_range(-10, 10) / 10))
			if $rat_run_timer.is_stopped():
				if rat.state not in [GlobalVars.states.CAM_10, GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
					$rat_run_timer.start(rat.attack_timer)
		
#func _on_texture_button_mouse_entered():
	#if cam_button_enable:
		#cam_button_enable = false
		#$cam_button.hide()
		#print("hovering")
		#
#func _on_texture_button_mouse_exited():
	#print("no longer hovering")
	
func _on_cam_button_button_down() -> void:
	if cams_on:
		close_cams()
	elif not cams_on and power > 0:
		open_cams()

	
func _process(delta):
	#if get_viewport().get_mouse_position().y < $cam_button.position.y and not cam_button_enable and not playing_cam_animation and power > 0:
		#cam_button_enable = true
		#$cam_button.show()
	$rat_left_warning.visible = (rat.state == GlobalVars.states.LEFT_DOOR)
	$rat_right_warning.visible = (rat.state == GlobalVars.states.RIGHT_DOOR)
	$vinnie_left_warning.visible = (vinnie.state == GlobalVars.states.LEFT_DOOR)
	$vinnie_right_warning.visible = (vinnie.state == GlobalVars.states.RIGHT_DOOR)
	$old_candy_left_warning.visible = (old_candy.state == GlobalVars.states.LEFT_DOOR and not cams_on)
	$old_candy_right_warning.visible = (old_candy.state == GlobalVars.states.RIGHT_DOOR and not cams_on)
	if power > 0:
		power -= (usage / 2.0) * delta * GlobalVars.usage_by_night[GlobalVars.night - 1]
	if (wind and GlobalVars.holding) or controller_wind:
		music_box += delta * 175
		if music_box > 1200: 
			music_box = 1200
	else:
		music_box -= delta * blank.ai_level * 2.5
		if music_box < 0:
			music_box = 0
			if $blank_timer.is_stopped():
				$blank_timer.start(10 - (blank.ai_level / 3) + (GlobalVars.rng.randi_range(-10, 10) / 10))
	if music_box > 0 and blank.state == GlobalVars.states.CAM_7:
		if not $blank_timer.is_stopped():
			$blank_timer.stop()
	$power_meter.text = "Power left: " + str(int(floor(power)))
	$cam_map/music_box.texture = load("res://assets/textures/music_box/music_box_" + str(int(floor(music_box / 100 + 0.5))) + ".png")
	if power < 0:
		if cams_on:
			close_cams()
		$office_background.texture = load("res://assets/textures/office_powerout.png")
		$audio_ambience_player.stop()
		$audio_music_box_player.stop()
		$audio_power_out_player.play()
		$power_meter.hide()
		$clock.hide()
		$usage_text.hide()
		$usage.hide()
		$night_text.hide()
		power = 0
		usage = 0
		left_door = false
		$office_buttons/left_door_button.set_texture_normal(load('res://assets/textures/door_button_outage.png'))
		right_door = false
		$office_buttons/right_door_button.set_texture_normal(load('res://assets/textures/door_button_outage.png'))
		vent_door = false
		$office_buttons/vent_door_button.set_texture_normal(load('res://assets/textures/door_button_outage.png'))
		$office_buttons/cam_button.hide()
	timer += delta
	if timer / 60 >= 6:
		game_over(true)
	$clock.text = ("12" if timer < 60 else str(int(floor(timer / 60)))) + ": " + (("0" + str(int(timer) % 60) if int(timer) % 60 < 10 else str(int(timer) % 60)))
	$usage.texture = load("res://assets/textures/usage/usage_" + str(usage) + ".png")
	if candy.state == GlobalVars.states.LEFT_DOOR or cindy.state == GlobalVars.states.LEFT_DOOR or chester.state == GlobalVars.states.LEFT_DOOR:
		$office_background/left_door_eyes.visible = true
	else:
		$office_background/left_door_eyes.visible = false
	if candy.state == GlobalVars.states.RIGHT_DOOR or cindy.state == GlobalVars.states.RIGHT_DOOR or chester.state == GlobalVars.states.RIGHT_DOOR:
		$office_background/right_door_eyes.visible = true
	else:
		$office_background/right_door_eyes.visible = false
	if penguin.state == GlobalVars.states.VENT:
		$office_background/vent_eyes.visible = true
	else:
		$office_background/vent_eyes.visible = false
	$office_background/left_door_sprite.visible = left_door
	$office_background/right_door_sprite.visible = right_door
	$office_background/vent_door_sprite.visible = vent_door
	if cams_on:
		var new_text = ""
		var selected_index = cams.find(selected_cam)
		$cam_map/cam_background.visible = (false if (selected_index == rat.state and rat.ai_level > 0) else true)
		$cam_map/cam_no_connection_label.visible = (selected_index == rat.state and rat.ai_level > 0)
		$cam_map/cam_background/cam_candy_eyes.visible = (selected_index == candy.state)
		$cam_map/cam_background/cam_cindy_eyes.visible = (selected_index == cindy.state)
		$cam_map/cam_background/cam_chester_eyes.visible = (selected_index == chester.state && chester.ai_level > 0)
		$cam_map/cam_background/cam_penguin_eyes.visible = (selected_index == penguin.state && penguin.ai_level > 0)
		$cam_map/cam_background/cam_cat_detector.visible = (selected_index == cat.state && cat.ai_level > 0)
		get_node("cam_map/cam_background/cam_vinnie_eyes_" + str(int(vinnie_state + 1))).visible = (vinnie.ai_level > 0 and vinnie_state < 3 and selected_index == vinnie.state)
		#new_text += ("Candy\n" if selected_index == candy.state else "")
		#new_text += ("Cindy\n" if selected_index == cindy.state else "")
		#new_text += ("Vinnie is in stage " + str(vinnie_state + 1) + '\n' if selected_index == vinnie.state else "")
		#new_text += ("Old Candy\n" if selected_index == old_candy.state else "")
		#new_text += ("Penguin\n" if selected_index == penguin.state else "")
		#new_text += ("Blank\n" if selected_index == blank.state else "")
		#new_text += ("Chester\n" if selected_index == chester.state else "")
		#new_text += ("Rat\n" if selected_index == rat.state else "")
		#new_text += ("Cat\n" if selected_index == cat.state else "")
		$cam_map/temp_info.text = new_text
	
		
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://main.tscn")
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$office_buttons/cam_button.grab_focus()
	$night_text.text = "Night " + str(GlobalVars.night)
	$candy_timer.start(candy.move_timer)
	$cindy_timer.start(cindy.move_timer)
	$vinnie_timer.start(vinnie.move_timer)
	$old_candy_timer.start(old_candy.move_timer)
	$penguin_timer.start(penguin.move_timer)
	$chester_timer.start(chester.move_timer)
	$cat_timer.start(cat.move_timer)
	$rat_timer.start(rat.move_timer)
	if GlobalVars.night == 1:
		$night1_ai_increase_timer.start(120)
		
func change_cam():
	$audio_change_player.play()
	if selected_cam == cams[GlobalVars.states.CAM_7]:
		$cam_map/cam_buttons/wind_button.show()
		$cam_map/music_box.show()
		$audio_music_box_player.volume_db = -14
	else:
		$cam_map/cam_buttons/wind_button.hide()
		$cam_map/music_box.hide()
		$audio_music_box_player.volume_db = -54
	if selected_cam == cams[GlobalVars.states.CAM_6]:
		$vinnie_advance_timer.stop()
		vinnie_move = false
	else:
		$vinnie_advance_timer.start(12 - vinnie.ai_level * 0.5 + (GlobalVars.rng.randi_range(-10, 10) / 10))
	if rat.state not in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
		if selected_cam == cams[rat.state]:
			$rat_run_timer.stop()
		else:
			if $rat_run_timer.is_stopped() and rat.state not in [GlobalVars.states.CAM_10, GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
				$rat_run_timer.start(rat.attack_timer)
	if selected_cam == cams[GlobalVars.states.CAM_11]:
		$cam_map/cam_buttons/audio_button.hide()
	else:
		$cam_map/cam_buttons/audio_button.show()
	
func game_over(win):
	if win:
		get_tree().change_scene_to_file("res://win.tscn")
	else:
		if not jumpscare:
			jumpscare = true
			$audio_jumpscare_player.play()
			$jumpscare_sprite.visible = true
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file("res://lose.tscn")

func _on_cam_1a_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_1A]:
		selected_cam = cams[GlobalVars.states.CAM_1A]
		change_cam()

func _on_cam_1b_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_1B]:
		selected_cam = cams[GlobalVars.states.CAM_1B]
		change_cam()

func _on_cam_2_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_2]:
		selected_cam = cams[GlobalVars.states.CAM_2]
		change_cam()
	
func _on_cam_3_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_3]:
		selected_cam = cams[GlobalVars.states.CAM_3]
		change_cam()
	
func _on_cam_4_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_4]:
		selected_cam = cams[GlobalVars.states.CAM_4]
		change_cam()
	
func _on_cam_5_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_5]:
		selected_cam = cams[GlobalVars.states.CAM_5]
		change_cam()
	
func _on_cam_6_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_6]:
		selected_cam = cams[GlobalVars.states.CAM_6]
		change_cam()
	
func _on_cam_7_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_7]:
		selected_cam = cams[GlobalVars.states.CAM_7]
		change_cam()
	
func _on_cam_8_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_8]:
		selected_cam = cams[GlobalVars.states.CAM_8]
		change_cam()
	
func _on_cam_9_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_9]:
		selected_cam = cams[GlobalVars.states.CAM_9]
		change_cam()
	
func _on_cam_10_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_10]:
		selected_cam = cams[GlobalVars.states.CAM_10]
		change_cam()
	
func _on_cam_11_button_down():
	if not selected_cam == cams[GlobalVars.states.CAM_11]:
		selected_cam = cams[GlobalVars.states.CAM_11]
		change_cam()
		
func _on_left_door_button_down():
	if power > 0:
		if not playing_ldoor_animation:
			if ldoor_disabled:
				$audio_door_player.stream = load("res://assets/audio/door_broken.mp3")
				$audio_door_player.play()
			else:
				$audio_door_player.stream = load("res://assets/audio/door.mp3")
				$audio_door_player.play()
				if not left_door:
					usage += 2
					left_door = true
					$office_buttons/left_door_button.set_texture_normal(load("res://assets/textures/door_button_closed.png"))
					playing_ldoor_animation = true
					await get_tree().create_timer(0.5).timeout
					playing_ldoor_animation = false
				else:
					usage -= 2
					left_door = false
					$office_buttons/left_door_button.set_texture_normal(load('res://assets/textures/door_button_open.png'))
					playing_ldoor_animation = true
					await get_tree().create_timer(0.5).timeout
					playing_ldoor_animation = false
			
func _on_right_door_button_down():
	if power > 0:
		if not playing_rdoor_animation:
			if rdoor_disabled:
				$audio_door_player.stream = load("res://assets/audio/door_broken.mp3")
				$audio_door_player.play()
			else:
				$audio_door_player.stream = load("res://assets/audio/door.mp3")
				$audio_door_player.play()
				if not right_door:
					usage += 2
					right_door = true
					$office_buttons/right_door_button.set_texture_normal(load('res://assets/textures/door_button_closed.png'))
					playing_rdoor_animation = true
					await get_tree().create_timer(0.5).timeout
					playing_rdoor_animation = false
				else:
					usage -= 2
					right_door = false
					$office_buttons/right_door_button.set_texture_normal(load('res://assets/textures/door_button_open.png'))
					playing_rdoor_animation = true
					await get_tree().create_timer(0.5).timeout
					playing_rdoor_animation = false
			
func _on_vent_door_button_down():
	if power > 0:
		if not playing_vdoor_animation:
			$audio_door_player.play()
			if not vent_door:
				usage += 2
				vent_door = true
				$office_buttons/vent_door_button.set_texture_normal(load('res://assets/textures/door_button_closed.png'))
				playing_vdoor_animation = true
				await get_tree().create_timer(0.5).timeout
				playing_vdoor_animation = false
			else:
				usage -= 2
				vent_door = false
				$office_buttons/vent_door_button.set_texture_normal(load('res://assets/textures/door_button_open.png'))
				playing_vdoor_animation = true
				await get_tree().create_timer(0.5).timeout
				playing_vdoor_animation = false
				
func _on_wind_button_mouse_entered():
	wind = true

func _on_wind_button_mouse_exited():
	wind = false
	
func get_text_from_state(state):
	if state == 0:
		return '1A'
	elif state == 1:
		return '1B'
	elif state == 12:
		return 'LEFT_DOOR'
	elif state == 13:
		return 'RIGHT_DOOR'
	elif state == 14:
		return 'VENT'
	elif state == 15:
		return 'OFFICE'
	else:
		return str(state)
	

#func _on_cam_anim_placeholder_open_timeout():
#	playing_cam_animation = false
#	$cam_map.visible = true
#	usage += 1
#	selected_cam.grab_focus()

#func _on_cam_anim_placeholder_close_timeout():
#	playing_cam_animation = false

func _on_candy_timer_timeout():
	if candy.ai_level > 0: print("Candy is trying to move...")
	if candy.state == GlobalVars.states.OFFICE:
		return
	if candy.attempt_move() or candy.attempt_count >= 1:
		var result = candy.move(left_door, right_door, vent_door)
		print("Candy moved to " + str(get_text_from_state(candy.state)))
		candy.attempt_count = 0
		if result == GlobalVars.states.LEFT_DOOR and candy.state == GlobalVars.states.OFFICE:
			ldoor_disabled = true
		elif result == GlobalVars.states.RIGHT_DOOR and candy.state == GlobalVars.states.OFFICE:
			rdoor_disabled = true
	else:
		if candy.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR]:
			candy.attempt_count += 1
	if not candy.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
		$candy_timer.start(candy.move_timer)
	else:
		if not candy.state == GlobalVars.states.OFFICE:
			$candy_timer.start(candy.attack_timer)
		
func _on_cindy_timer_timeout():
	if cindy.ai_level > 0: print("Cindy is trying to move...")
	if cindy.state == GlobalVars.states.OFFICE:
		return
	if cindy.attempt_move() or cindy.attempt_count >= 1:
		var result = cindy.move(left_door, right_door, vent_door)
		print("Cindy moved to " + str(get_text_from_state(cindy.state)))
		cindy.attempt_count = 0
		if result == GlobalVars.states.LEFT_DOOR and cindy.state == GlobalVars.states.OFFICE:
			ldoor_disabled = true
		elif result == GlobalVars.states.RIGHT_DOOR and cindy.state == GlobalVars.states.OFFICE:
			rdoor_disabled = true
	else:
		if cindy.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR]:
			cindy.attempt_count += 1
	if not cindy.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
		$cindy_timer.start(cindy.move_timer)
	else:
		if not cindy.state == GlobalVars.states.OFFICE:
			$cindy_timer.start(cindy.attack_timer)


func _on_cam_jumpscare_timer_timeout():
	close_cams()


func _on_vinnie_timer_timeout():
	if vinnie.ai_level > 0: print("Vinnie is trying to move...")
	if vinnie.state == GlobalVars.states.LEFT_DOOR or vinnie.state == GlobalVars.states.RIGHT_DOOR:
		vinnie.move(left_door, right_door, vent_door)
		if vinnie.state == GlobalVars.states.OFFICE:
			print('boo')
			game_over(false)
		else:
			$audio_bang_player.play()
			print('Vinnie moved to 6')
			if not (cams_on and selected_cam == cams[GlobalVars.states.CAM_6]):
				$vinnie_advance_timer.start(12 - vinnie.ai_level * 0.5 + (GlobalVars.rng.randi_range(-10, 10) / 10))
	if vinnie_move:
		if vinnie.attempt_move():
			if vinnie_state < 2:
				vinnie_state += 1
				print("Vinnie is in stage " + str(vinnie_state + 1))
			else:
				vinnie_state = 0
				vinnie.move(left_door, right_door, vent_door)
				print("Vinnie is running to " + get_text_from_state(vinnie.state))
				if vinnie.state == GlobalVars.states.LEFT_DOOR:
					$audio_vinnie_player.stream = load("res://assets/audio/vinnie_left.mp3")
				else:
					$audio_vinnie_player.stream = load("res://assets/audio/vinnie_right.mp3")
				$audio_vinnie_player.play()
	if vinnie.state == GlobalVars.states.LEFT_DOOR or vinnie.state == GlobalVars.states.RIGHT_DOOR:
		$vinnie_timer.start(vinnie.attack_timer)
	else:
		$vinnie_timer.start(vinnie.move_timer)


func _on_vinnie_advance_timer_timeout():
	vinnie_move = true


func _on_old_candy_timer_timeout():
	if old_candy.ai_level > 0: print("Old Candy is trying to move...")
	if old_candy.state == GlobalVars.states.OFFICE:
		print("boo")
		game_over(false)
	if old_candy.attempt_move() or old_candy.attempt_count >= 1:
		old_candy.move(left_door, right_door, vent_door)
		old_candy.attempt_count = 0
		print("Old Candy moved to " + str(get_text_from_state(old_candy.state)))
	else:
		if old_candy.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR]:
			old_candy.attempt_count += 1
	if not old_candy.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
		$old_candy_timer.start(old_candy.move_timer)
	else:
		$old_candy_timer.start(old_candy.attack_timer)


func _on_penguin_timer_timeout():
	if penguin.ai_level > 0: print("Penguin is trying to move...")
	if penguin.state == GlobalVars.states.OFFICE:
		pass
	if penguin.attempt_move() or penguin.attempt_count >= 1:
		penguin.move(left_door, right_door, vent_door)
		penguin.attempt_count = 0
		print("Penguin moved to " + str(get_text_from_state(penguin.state)))
		if penguin.state == GlobalVars.states.OFFICE:
			ldoor_disabled = true
			rdoor_disabled = true
			usage += 2
	else:
		if penguin.state == GlobalVars.states.VENT:
			penguin.attempt_count += 1
	if not penguin.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
		$penguin_timer.start(penguin.move_timer)
	else:
		if not penguin.state == GlobalVars.states.OFFICE:
			$penguin_timer.start(penguin.attack_timer)


func _on_blank_timer_timeout():
	if blank.ai_level > 0: print("Blank is trying to move...")
	if blank.state == GlobalVars.states.LEFT_DOOR:
		if left_door:
			return
		else:
			blank.move(left_door, right_door, vent_door)
			$blank_timer.start(blank.attack_timer + (GlobalVars.rng.randi_range(-20, 20) / 10))
			print("Blank moved to " + str(get_text_from_state(blank.state)))
	elif blank.state == GlobalVars.states.RIGHT_DOOR:
		if right_door:
			return
		else:
			blank.move(left_door, right_door, vent_door)
			$blank_timer.start(blank.attack_timer + (GlobalVars.rng.randi_range(-20, 20) / 10))
			print("Blank moved to " + str(get_text_from_state(blank.state)))
	elif blank.state == GlobalVars.states.OFFICE:
		print("boo")
		game_over(false)
	else:
		if blank.attempt_move():
			blank.move(left_door, right_door, vent_door)
			print("Blank moved to " + str(get_text_from_state(blank.state)))
	if not blank.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
		$blank_timer.start(10 - (blank.ai_level / 3) + (GlobalVars.rng.randi_range(-10, 10) / 10))
	else:
		$blank_timer.start(blank.attack_timer + (GlobalVars.rng.randi_range(-30, 30) / 10))

func _on_chester_timer_timeout():
	if chester.ai_level > 0: print("Chester is trying to move...")
	if chester.state == GlobalVars.states.LEFT_DOOR:
		if left_door:
			return
		else:
			chester.move(left_door, right_door, vent_door)
			$chester_timer.start(chester.attack_timer)
			print("Chester moved to " + str(get_text_from_state(chester.state)))
	elif chester.state == GlobalVars.states.RIGHT_DOOR:
		if right_door:
			return
		else:
			chester.move(left_door, right_door, vent_door)
			$chester_timer.start(chester.attack_timer)
			print("Chester moved to " + str(get_text_from_state(chester.state)))
	elif chester.state == GlobalVars.states.OFFICE:
		print("boo")
		game_over(false)
	else:
		if chester.attempt_move():
			chester.move(left_door, right_door, vent_door)
			print("Chester moved to " + str(get_text_from_state(chester.state)))
	if not chester.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
		$chester_timer.start(chester.move_timer)
	else:
		$chester_timer.start(chester.attack_timer)
	
func _on_cat_timer_timeout():
	if cat.ai_level > 0: print("Cat is trying to move...")
	if cat.state == GlobalVars.states.LEFT_DOOR:
		if left_door:
			return
		else:
			cat.move(left_door, right_door, vent_door)
			$cat_timer.start(cat.attack_timer)
			print("Cat moved to " + str(get_text_from_state(cat.state)))
	elif cat.state == GlobalVars.states.RIGHT_DOOR:
		if right_door:
			return
		else:
			cat.move(left_door, right_door, vent_door)
			$cat_timer.start(cat.attack_timer)
			print("Cat moved to " + str(get_text_from_state(cat.state)))
	elif cat.state == GlobalVars.states.VENT:
		if vent_door:
			return
		else:
			cat.move(left_door, right_door, vent_door)
			$cat_timer.start(cat.attack_timer)
			print("Cat moved to " + str(get_text_from_state(cat.state)))
	elif cat.state == GlobalVars.states.OFFICE:
		print("boo")
		game_over(false)
	else:
		if cat.attempt_move():
			cat.move(left_door, right_door, vent_door)
			print("Cat moved to " + str(get_text_from_state(cat.state)))
	if not cat.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.VENT, GlobalVars.states.OFFICE]:
		$cat_timer.start(cat.move_timer)
	else:
		$cat_timer.start(cat.attack_timer)
		
func _on_rat_timer_timeout():
	if rat.ai_level > 0: print("Rat is trying to move...")
	if rat_run:
		if rat.state == GlobalVars.states.LEFT_DOOR:
			if left_door:
				$audio_bang_player.play()
				await get_tree().create_timer(0.25).timeout
				if GlobalVars.rng.randi_range(1, 100) < 50:
					rat_run = true
					$rat_timer.start(2.5)
					if GlobalVars.rng.randi_range(1, 100) < 50:
						rat.state = GlobalVars.states.LEFT_DOOR
						print("Rat is running to LEFT_DOOR")
						$audio_run_player.stream = load("res://assets/audio/run_left.mp3")
						$audio_run_player.play()
					else:
						rat.state = GlobalVars.states.RIGHT_DOOR
						print("Rat is running to RIGHT_DOOR")
						$audio_run_player.stream = load("res://assets/audio/run_right.mp3")
						$audio_run_player.play()
				else:
					rat_run = false
					rat.state = GlobalVars.states.CAM_10
					$rat_timer.start(rat.move_timer)
			else:
				print("boo")
				game_over(false)
		elif rat.state == GlobalVars.states.RIGHT_DOOR:
			if right_door:
				$audio_bang_player.play()
				await get_tree().create_timer(0.25).timeout
				if GlobalVars.rng.randi_range(1, 100) < 50:
					rat_run = true
					$rat_timer.start(2.5)
					if GlobalVars.rng.randi_range(1, 100) < 50:
						rat.state = GlobalVars.states.LEFT_DOOR
						print("Rat is running to LEFT_DOOR")
						$audio_run_player.stream = load("res://assets/audio/run_left.mp3")
						$audio_run_player.play()
					else:
						rat.state = GlobalVars.states.RIGHT_DOOR
						print("Rat is running to RIGHT_DOOR")
						$audio_run_player.stream = load("res://assets/audio/run_right.mp3")
						$audio_run_player.play()
				else:
					rat_run = false
					rat.state = GlobalVars.states.CAM_10
					$rat_timer.start(rat.move_timer)
			else:
				print("boo")
				game_over(false)
	else:
		if rat.state == GlobalVars.states.OFFICE:
			print("boo")
			game_over(false)
		if rat.attempt_move() or rat.attempt_count >= 1:
			rat.move(left_door, right_door, vent_door)
			print("Rat moved to " + str(get_text_from_state(rat.state)))
			if not rat.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
				if not (cams_on and selected_cam == cams[rat.state]) and not rat.state == GlobalVars.states.CAM_10:
					$rat_run_timer.start(rat.attack_timer)
		else:
			if rat.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR]:
				rat.attempt_count += 1
		if not rat.state in [GlobalVars.states.LEFT_DOOR, GlobalVars.states.RIGHT_DOOR, GlobalVars.states.OFFICE]:
			$rat_timer.start(rat.move_timer)
		else:
			$rat_timer.start(rat.attack_timer)

func _on_rat_run_timer_timeout():
	rat_run = true
	$rat_timer.start(2.5)
	if GlobalVars.rng.randi_range(1, 100) < 50:
		rat.state = GlobalVars.states.LEFT_DOOR
		print("Rat is running to LEFT_DOOR")
		$audio_run_player.stream = load("res://assets/audio/run_left.mp3")
		$audio_run_player.play()
	else:
		rat.state = GlobalVars.states.RIGHT_DOOR
		print("Rat is running to RIGHT_DOOR")
		$audio_run_player.stream = load("res://assets/audio/run_right.mp3")
		$audio_run_player.play()

func _on_audio_button_down():
	if audio_playing == -1:
		audio_playing = cams.find(selected_cam)
		$cam_map/cam_buttons/audio_button.disabled = true
		$cam_map/cam_buttons/audio_button.text = "Playing..."
		$audio_lure_player.play()
		$audio_timer.start(1.5)
		if chester.state in GlobalVars.audio_adj[audio_playing] and chester.ai_level > 0:
			if GlobalVars.rng.randi_range(1, 100) < 100 - chester.ai_level / 2:
				$chester_timer.start(chester.move_timer - chester.ai_level / 5)
				await get_tree().create_timer(1).timeout
				chester.state = audio_playing
				print("Chester was lured to " + get_text_from_state(chester.state))
		if cat.state in GlobalVars.audio_adj[audio_playing] and cat.ai_level > 0:
			if GlobalVars.rng.randi_range(1, 100) < 100 - cat.ai_level / 2:
				$cat_timer.start(cat.move_timer - cat.ai_level / 10)
				await get_tree().create_timer(1).timeout
				cat.state = audio_playing
				print("Cat was lured to " + get_text_from_state(cat.state))
		
func _on_audio_timer_timeout():
	if audio_playing == -2:
		audio_playing = -1
		$cam_map/cam_buttons/audio_button.disabled = false
		$cam_map/cam_buttons/audio_button.text = "Play Audio"
	else:
		audio_playing = -2
		$cam_map/cam_buttons/audio_button.text = "Recharging..."
		$audio_timer.start(8.5)


func _on_night_1_ai_increase_timer_timeout():
	candy.ai_level += 1
	cindy.ai_level += 1
	blank.ai_level += 4


func _on_arduino_data_recieved(myString: String) -> void:
	var old_result = myString.split(" ")
	var result = []
	result.resize(len(old_result))
	for i in range(len(old_result)):
		result[i] = float(old_result[i])
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
	if right_button_pressed and previous_right == 0:
		if cams_on and $cam_map/cam_buttons/audio_button.visible == true:
			_on_audio_button_down()
		else:
			_on_right_door_button_down()
	previous_right = right_button_pressed
	if left_button_pressed:
		if cams_on and $cam_map/cam_buttons/wind_button.visible == true:
			controller_wind = true
		elif previous_left == 0:
			controller_wind = false
			_on_left_door_button_down()
		else:
			controller_wind = false
	else:
		controller_wind = false
	previous_left = left_button_pressed
	if up_button_pressed and previous_up == 0:
		if cams_on:
			var event = InputEventKey.new()
			event.keycode = KEY_ENTER
			event.pressed = true
			Input.parse_input_event(event)
		
			event = InputEventKey.new()
			event.keycode = KEY_ENTER
			event.pressed = false
			Input.parse_input_event(event)
		else:
			_on_vent_door_button_down()
	previous_up = up_button_pressed
	if down_button_pressed and previous_down == 0:
		_on_cam_button_button_down()
	previous_down = down_button_pressed
	if start_button_pressed and previous_start == 0:
		get_tree().change_scene_to_file("res://main.tscn")
	previous_start = start_button_pressed
	
#func _on_arduino_data_recieved(myString: String) -> void:
	#print(myString)
	#var data = myString.split(" ")
	#var vert =  roundc(data[0])
	#var click = int(data[5])
	#
	#if not controller_ready:
		#if click == 0:
			#controller_ready = true
	#
	#var side = KEY_DOWN if vert < 0 else KEY_UP
	#if vert != 0 and (previous_vert == 0):
		#var event = InputEventKey.new()
		#event.keycode = side
		#event.pressed = true
		#Input.parse_input_event(event)
		#
		#event = InputEventKey.new()
		#event.keycode = side
		#event.pressed = false
		#Input.parse_input_event(event)
	#previous_vert = vert
	#
	#if controller_ready:
		#if click and (previous_click == 0):
			#var event = InputEventKey.new()
			#event.keycode = KEY_ENTER
			#event.pressed = true
			#Input.parse_input_event(event)
			#
			#event = InputEventKey.new()
			#event.keycode = KEY_ENTER
			#event.pressed = false
			#Input.parse_input_event(event)
		#previous_click = click
#
#
#func roundc(value: String) -> int:
	#return floor(float(value) + 0.5)
