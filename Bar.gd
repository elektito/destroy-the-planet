extends 'Building.gd'
tool

const type := Global.BuildingType.BAR
const effects := [Global.StatType.ADS]

var levels = [
	{
		'number': 1,
		'description': 'Level 1 bar.',
		'base_ads': 1,
	},
	{
		'number': 2,
		'description': 'Level 2 bar.',
		'base_ads': 2,
	},
	{
		'number': 3,
		'description': 'Level 3 bar.',
		'base_ads': 3,
	},
	{
		'number': 4,
		'description': 'Level 4 bar.',
		'base_ads': 4,
	},
	{
		'number': 5,
		'description': 'Level 5 bar.',
		'base_ads': 5,
	},
	{
		'number': 6,
		'description': 'Level 6 bar.',
		'base_ads': 6,
	},
	{
		'number': 7,
		'description': 'Level 7 bar.',
		'base_ads': 7,
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
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.ADS, get_ads())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func get_stats():
	return [
		{
			'type': Global.StatType.LEVEL,
			'value': str(level),
		},
		{
			'type': Global.StatType.ADS,
			'value': str(get_ads()),
		},
	]


func get_ads():
	return current_level['base_ads']


func get_property(property):
	if property == Global.StatType.ADS:
		return get_ads()


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


func perform_action(action, _count):
	match action['name']:
		'level':
			level += 1
			current_level = levels[level - 1]
			emit_signal("upgraded", self)
			emit_signal("info_updated", self, Global.StatType.ADS, get_ads())
			update_upgrade_label(self)


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_upgrade_label(self)
