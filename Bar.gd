extends 'Building.gd'
tool

const type := Global.BuildingType.BAR

var levels = [
	{
		'number': 1,
		'description': 'Level 1 bar.',
		'base_entertainment': 2,
	},
	{
		'number': 2,
		'description': 'Level 2 bar.',
		'base_entertainment': 10,
	},
	{
		'number': 3,
		'description': 'Level 3 bar.',
		'base_entertainment': 500,
	},
	{
		'number': 4,
		'description': 'Level 4 bar.',
		'base_entertainment': 25000,
	},
	{
		'number': 5,
		'description': 'Level 5 bar.',
		'base_entertainment': 1000000,
	},
	{
		'number': 6,
		'description': 'Level 6 bar.',
		'base_entertainment': 50000000,
	},
	{
		'number': 7,
		'description': 'Level 7 bar.',
		'base_entertainment': 1000000000,
	},
]
var current_level = levels[0]

var building_name = 'Bar'
var description = 'Where people go to have fun. Happy people consume more!'
var level := 1

var world

func init(_world):
	world = _world
	update_upgrade_label(self)


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
		var next_level = levels[level] # level is one based, so levels[level] is next level
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade bar to level ' + str(level + 1) + '.',
			'price': int(pow(100, level)),
			'stats': Global.get_level_upgrade_stats(current_level, next_level),
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
			current_level = levels[level - 1]
			emit_signal("upgraded", self)
			emit_signal("info_updated", self, Global.StatType.ENTERTAINMENT, get_entertainment())
			update_upgrade_label(self)


func notify_update(item):
	if item == Global.StatType.MONEY:
		update_upgrade_label(self)
