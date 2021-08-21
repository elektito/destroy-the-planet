extends Node2D

const MAX_LEVEL := 7

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


func get_stats():
	return [
		{
			'type': Global.StatType.MONEY,
			'value': '100',
		},
		{
			'type': Global.StatType.POLLUTION,
			'value': '200',
		},
		{
			'type': Global.StatType.USAGE,
			'value': '10',
		},
	]


func get_actions():
	var actions = []
	if level < MAX_LEVEL:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade factory to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times.'
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
