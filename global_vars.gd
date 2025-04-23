extends Node

class Probabilities:
	var location
	var probabilities
	
	func _init(_location, _probabilities):
		location = _location
		probabilities = _probabilities
	
class Probability:
	var to_go
	var chance
	
	func _init(_to_go, _chance):
		to_go = _to_go
		chance = _chance
			

enum states {CAM_1A, CAM_1B, CAM_2, CAM_3, CAM_4, CAM_5, CAM_6, CAM_7, CAM_8, CAM_9, CAM_10, CAM_11, LEFT_DOOR, RIGHT_DOOR, VENT, OFFICE}

var rng = RandomNumberGenerator.new()

var night = 4
var old_night = night
var holding = false
var loaded = false
var custom_night_unlocked = 0

var usage_by_night = [0.14, 0.14, 0.14, 0.14, 0.14, 0.14]

# out of 25, 20 available for rng even at max difficulty
var blank_ai_by_night = [0, 6, 8, 10, 0, 0]
var candy_ai_by_night = [0, 5, 8, 13, 0, 0]
var cindy_ai_by_night = [0, 6, 9, 12, 0, 0]
var vinnie_ai_by_night = [0, 3, 6, 9, 0, 0]
var old_candy_ai_by_night = [0, 0, 3, 8, 0, 0]
var penguin_ai_by_night = [0, 3, 6, 10, 0, 0]
var chester_ai_by_night = [0, 0, 0, 7, 0, 0]
var rat_ai_by_night = [0, 0, 0, 0, 12, 0]
var cat_ai_by_night = [0, 0, 0, 0, 12, 0]

var candy_timer = 5
var cindy_timer = 4.5
var penguin_timer = 6
var old_candy_timer = 8
var chester_timer = 10
var vinnie_timer = 8
var blank_timer = 10
var rat_timer = 6
var cat_timer = 8

var candy_attack_timer = 6.5
var cindy_attack_timer = 6.5
var vinnie_attack_timer = 3.5
var old_candy_attack_timer = 8
var penguin_attack_timer = 6.5
var blank_attack_timer = 7
var chester_attack_timer = 9
var rat_attack_timer = 5
var cat_attack_timer = 5

var audio_adj = [[GlobalVars.states.CAM_1B],
				[GlobalVars.states.CAM_1A ,GlobalVars.states.CAM_2, GlobalVars.states.CAM_3, GlobalVars.states.CAM_4, GlobalVars.states.CAM_10],
				[GlobalVars.states.CAM_1B],
				[GlobalVars.states.CAM_1B],
				[GlobalVars.states.CAM_1B, GlobalVars.states.CAM_5, GlobalVars.states.CAM_8, GlobalVars.states.CAM_9],
				[GlobalVars.states.CAM_4, GlobalVars.states.CAM_6, GlobalVars.states.CAM_7, GlobalVars.states.CAM_8],
				[GlobalVars.states.CAM_5, GlobalVars.states.CAM_7],
				[GlobalVars.states.CAM_5, GlobalVars.states.CAM_6],
				[GlobalVars.states.CAM_4, GlobalVars.states.CAM_5, GlobalVars.states.CAM_9, GlobalVars.states.LEFT_DOOR],
				[GlobalVars.states.CAM_4, GlobalVars.states.CAM_8, GlobalVars.states.RIGHT_DOOR],
				[GlobalVars.states.CAM_1B],
				[GlobalVars.states.CAM_8, GlobalVars.states.CAM_9],
				[GlobalVars.states.CAM_8],
				[GlobalVars.states.CAM_9]]

var candy_probs = [Probabilities.new(states.CAM_1A, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_1B, [Probability.new(states.CAM_3, 25), Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_2, []),
				Probabilities.new(states.CAM_3, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_1B, 10), Probability.new(states.CAM_8, 55), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, []),
				Probabilities.new(states.CAM_6, []),
				Probabilities.new(states.CAM_7, []),
				Probabilities.new(states.CAM_8, [Probability.new(states.CAM_9, 5), Probability.new(states.CAM_4, 15), Probability.new(states.LEFT_DOOR, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.CAM_8, 5), Probability.new(states.CAM_4, 15), Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_10, []),
				Probabilities.new(states.CAM_11, [])]
				
var cindy_probs = [Probabilities.new(states.CAM_1A, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_1B, [Probability.new(states.CAM_2, 25), Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_2, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_3, []),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_1B, 10), Probability.new(states.CAM_8, 55), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, []),
				Probabilities.new(states.CAM_6, []),
				Probabilities.new(states.CAM_7, []),
				Probabilities.new(states.CAM_8, [Probability.new(states.CAM_9, 5), Probability.new(states.CAM_4, 15), Probability.new(states.LEFT_DOOR, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.CAM_8, 5), Probability.new(states.CAM_4, 15), Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_10, []),
				Probabilities.new(states.CAM_11, [])]

var vinnie_probs = [Probabilities.new(states.CAM_1A, []),
				Probabilities.new(states.CAM_1B, []),
				Probabilities.new(states.CAM_2, []),
				Probabilities.new(states.CAM_3, []),
				Probabilities.new(states.CAM_4, []),
				Probabilities.new(states.CAM_5, []),
				Probabilities.new(states.CAM_6, [Probability.new(states.LEFT_DOOR, 50), Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_7, []),
				Probabilities.new(states.CAM_8, []),
				Probabilities.new(states.CAM_9, []),
				Probabilities.new(states.CAM_10, []),
				Probabilities.new(states.CAM_11, []),]
				
var old_candy_probs = [Probabilities.new(states.CAM_1A, []),
				Probabilities.new(states.CAM_1B, [Probability.new(states.CAM_3, 25), Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_2, []),
				Probabilities.new(states.CAM_3, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, []),
				Probabilities.new(states.CAM_6, []),
				Probabilities.new(states.CAM_7, []),
				Probabilities.new(states.CAM_8, [Probability.new(states.CAM_9, 5), Probability.new(states.CAM_4, 15), Probability.new(states.LEFT_DOOR, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.CAM_8, 5), Probability.new(states.CAM_4, 15), Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_10, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_11, [])]
				
var penguin_probs = [Probabilities.new(states.CAM_1A, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_1B, [Probability.new(states.CAM_2, 25), Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_2, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_3, []),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_1B, 10), Probability.new(states.CAM_8, 55), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, []),
				Probabilities.new(states.CAM_6, []),
				Probabilities.new(states.CAM_7, []),
				Probabilities.new(states.CAM_8, [Probability.new(states.CAM_9, 5), Probability.new(states.CAM_11, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.CAM_8, 5), Probability.new(states.CAM_11, 100)]),
				Probabilities.new(states.CAM_10, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_11, [Probability.new(states.VENT, 100)])]
				
var blank_probs = [Probabilities.new(states.CAM_1A, []),
				Probabilities.new(states.CAM_1B, []),
				Probabilities.new(states.CAM_2, []),
				Probabilities.new(states.CAM_3, []),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_6, []),
				Probabilities.new(states.CAM_7, [Probability.new(states.CAM_5, 100)]),
				Probabilities.new(states.CAM_8, [Probability.new(states.LEFT_DOOR, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_10, []),
				Probabilities.new(states.CAM_11, []),]

var chester_probs = [Probabilities.new(states.CAM_1A, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_1B, [Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_2, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_3, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_6, [Probability.new(states.CAM_5, 100)]),
				Probabilities.new(states.CAM_7, [Probability.new(states.CAM_5, 100)]),
				Probabilities.new(states.CAM_8, [Probability.new(states.LEFT_DOOR, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_10, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_11, [])]
				
var cat_probs = [Probabilities.new(states.CAM_1A, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_1B, [Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_2, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_3, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_6, [Probability.new(states.CAM_5, 100)]),
				Probabilities.new(states.CAM_7, [Probability.new(states.CAM_5, 100)]),
				Probabilities.new(states.CAM_8, [Probability.new(states.CAM_11, 20), Probability.new(states.LEFT_DOOR, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.CAM_11, 20), Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_10, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_11, [Probability.new(states.VENT, 100)])]
				
var rat_probs = [Probabilities.new(states.CAM_1A, []),
				Probabilities.new(states.CAM_1B, [Probability.new(states.CAM_4, 100)]),
				Probabilities.new(states.CAM_2, []),
				Probabilities.new(states.CAM_3, []),
				Probabilities.new(states.CAM_4, [Probability.new(states.CAM_8, 50), Probability.new(states.CAM_9, 100)]),
				Probabilities.new(states.CAM_5, []),
				Probabilities.new(states.CAM_6, []),
				Probabilities.new(states.CAM_7, []),
				Probabilities.new(states.CAM_8, [Probability.new(states.CAM_9, 5), Probability.new(states.CAM_4, 15), Probability.new(states.LEFT_DOOR, 100)]),
				Probabilities.new(states.CAM_9, [Probability.new(states.CAM_8, 5), Probability.new(states.CAM_4, 15), Probability.new(states.RIGHT_DOOR, 100)]),
				Probabilities.new(states.CAM_10, [Probability.new(states.CAM_1B, 100)]),
				Probabilities.new(states.CAM_11, [])]
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if event.pressed:
				holding = true
			else:
				holding = false
