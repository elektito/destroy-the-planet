extends Node2D

const type := Global.BuildingType.APARTMENT_BUILDING
const MAX_LEVEL := 9

var building_name = 'Apartment Building'
var description = 'Provides housing for the ultimate resource users and pollution producers: people.'
var level := 1

var world

func init(world):
	self.world = world


func get_stats():
	return [
		{
			'type': Global.StatType.POPULATION_CAP,
			'value': '10000',
		},
		{
			'type': Global.StatType.POPULATION_INCREASE,
			'value': '100',
		},
	]


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
