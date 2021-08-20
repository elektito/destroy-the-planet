extends Node2D

var building_name = 'Factory'
var description = 'A good ol\' factory. Consumes some resources and pollutes a heck of a lot more.'
var level := 1

var resource_usage = 1 setget set_resource_usage, get_resource_usage
var pollution = 5 setget set_pollution, get_pollution

func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 1


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 5


func get_actions():
	return [
		{'name': 'Upgrade to Level ' + str(level + 1), 'description': 'Upgrade to level ' + str(level + 1) + ' which is way cooler.'}
	]


func perform_action(action):
	match action['name']:
		'Upgrade to Level 2', 'Uprade to Level 3':
			level += 1
