@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("Arduino", "Node", preload("res://addons/arduino/arduino.cs"), preload("res://addons/arduino/arduino_small.png"))


func _exit_tree() -> void:
	remove_custom_type("Arduino")
