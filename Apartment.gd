extends Node2D

const MAX_LEVEL := 9

var building_name = 'Apartment Building'
var description = 'Provides housing for the ultimate resource users and pollution producers: people.'
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
			'description': 'Upgrade apartment building to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times. Population capacity will be double.'
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
