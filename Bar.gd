extends Node2D

const type := Global.BuildingType.BAR
const MAX_LEVEL := 7

var building_name = 'Bar'
var description = 'Where people go to have fun.'
var level := 1

var world

func init(world):
	self.world = world


func get_stats():
	return [
		{
			'type': Global.StatType.ENTERTAINMENT,
			'value': '100',
		},
	]


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
