extends Node2D

const MAX_LEVEL := 5

var building_name = 'Mine'
var description = 'Mines resource from the planet, accelerating certain doom.'
var level := 1

var resource_usage = 1 setget set_resource_usage, get_resource_usage
var pollution = 5 setget set_pollution, get_pollution

func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 5


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 1


func get_stats():
	return [
		{
			'type': Global.StatType.POLLUTION,
			'value': '20',
		},
		{
			'type': Global.StatType.USAGE,
			'value': '500',
		},
		{
			'type': Global.StatType.MINING,
			'value': '1000',
		},
	]


func get_actions():
	var actions = []
	if level < MAX_LEVEL:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade mine to level ' + str(level + 1) + '. Resource extraction will be ten times the current amount and the pollution will be double. '
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
