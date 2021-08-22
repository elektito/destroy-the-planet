extends Node2D

const type := Global.BuildingType.POWERPLANT
const MAX_LEVEL := 8

var building_name = 'Coal Powerplant'
var description = 'The best kind of power plant there is.'
var level := 1

var world

func init(world):
	self.world = world


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
