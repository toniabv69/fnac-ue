extends Node2D


func _ready():
	await get_tree().create_timer(5).timeout
	$you_win.text = "6 AM"
	await get_tree().create_timer(5).timeout
	if GlobalVars.night < 5:
		GlobalVars.night += 1
		get_tree().change_scene_to_file("res://pre_night.tscn")
	else:
		GlobalVars.custom_night_unlocked = true
		get_tree().change_scene_to_file("res://main.tscn")
	
