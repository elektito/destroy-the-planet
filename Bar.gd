extends Node2D

const MAX_LEVEL := 7

var building_name = 'Bar'
var description = 'Where people go to have fun.'
var level := 1

var resource_usage = 1 setget set_resource_usage, get_resource_usage
var pollution = 1 setget set_pollution, get_pollution

func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 1


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 1


func get_actions():
	var actions = []
	if level < MAX_LEVEL:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade bar to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times. Increased entertainment will cause demand to be ten fold.'
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
