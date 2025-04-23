extends Node2D

@onready
var night_node = get_node("night")


func _ready():
	night_node.text = "Night " + str(GlobalVars.night)
	await get_tree().create_timer(3.5).timeout
	get_tree().change_scene_to_file("res://night.tscn")
