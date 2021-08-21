extends Node2D

const MAX_LEVEL := 8

var building_name = 'Coal Powerplant'
var description = 'The best kind of power plant there is.'
var level := 1

var resource_usage = 2 setget set_resource_usage, get_resource_usage
var pollution = 4 setget set_pollution, get_pollution

func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 2


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 4


func get_stats():
	return [
		{
			'type': Global.StatType.POLLUTION,
			'value': '80',
		},
		{
			'type': Global.StatType.USAGE,
			'value': '100',
		},
		{
			'type': Global.StatType.POWER,
			'value': '2000',
		},
	]


func get_actions():
	var actions = []
	if level < MAX_LEVEL:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade powerplant to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times. Electricity production will be ten times.'
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
