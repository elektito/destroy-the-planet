extends Node2D

signal upgraded(building)
signal info_updated(building, item)

const type := Global.BuildingType.BAR

var levels = [
	{
		'number': 1,
		'description': 'Your rudimentary basic factory.',
		'base_entertainment': 1,
	},
	{
		'number': 2,
		'description': 'Small factory.',
		'base_entertainment': 10,
	},
	{
		'number': 3,
		'description': 'Partially upgraded factory.',
		'base_entertainment': 100,
	},
	{
		'number': 4,
		'description': 'Medium-sized factory.',
		'base_entertainment': 1000,
	},
	{
		'number': 5,
		'description': 'Above-medium factory.',
		'base_entertainment': 10000,
	},
	{
		'number': 6,
		'description': 'Almost-there factory.',
		'base_entertainment': 100000,
	},
	{
		'number': 7,
		'description': 'Beast of a factory.',
		'base_entertainment': 1000000,
	},
]
var current_level = levels[0]

var building_name = 'Bar'
var description = 'Where people go to have fun. Happy people consume more!'
var level := 1

var world

func init(world):
	self.world = world


func get_stats():
	return [
		{
			'type': Global.StatType.LEVEL,
			'value': str(level),
		},
		{
			'type': Global.StatType.ENTERTAINMENT,
			'value': str(get_entertainment()),
		},
	]


func get_entertainment():
	return current_level['base_entertainment']


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade bar to level ' + str(level + 1) + '.',
			'price': (level + 1) * 1000,
			'stats': Global.get_level_upgrade_stats(current_level, levels[level + 1]),
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
			current_level = levels[level - 1]
			emit_signal("upgraded", self)
			emit_signal("info_updated", self, "entertainment")


func notify_update(item):
	pass
