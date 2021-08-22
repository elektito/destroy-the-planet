extends Node2D

signal upgraded(building)
signal info_updated(building, item)

const type := Global.BuildingType.POWERPLANT

var levels = [
	{
		'number': 1,
		'description': 'Tiny powerplant.',
		'base_pollution_per_cycle': 10,
		'base_resource_usage_per_cycle': 1,
		'base_power': 1,
	},
	{
		'number': 2,
		'description': 'Small powerplant.',
		'base_pollution_per_cycle': 100,
		'base_resource_usage_per_cycle': 10,
		'base_power': 10,
	},
	{
		'number': 3,
		'description': 'Not quite medium powerplant.',
		'base_pollution_per_cycle': 1000,
		'base_resource_usage_per_cycle': 100,
		'base_power': 100,
	},
	{
		'number': 4,
		'description': 'Medium-sized powerplant.',
		'base_pollution_per_cycle': 10000,
		'base_resource_usage_per_cycle': 500,
		'base_power': 1000,
	},
	{
		'number': 5,
		'base_pollution_per_cycle': 100000,
		'base_resource_usage_per_cycle': 1000,
		'base_power': 10000,
	},
	{
		'number': 6,
		'description': 'Big powerplant.',
		'base_pollution_per_cycle': 1000000,
		'base_resource_usage_per_cycle': 10000,
		'base_power': 100000,
	},
	{
		'number': 7,
		'description': 'Huge powerplant.',
		'base_pollution_per_cycle': 10000000,
		'base_resource_usage_per_cycle': 50000,
		'base_power': 1000000,
	},
	{
		'number': 8,
		'description': 'Gigantic powerplant.',
		'base_pollution_per_cycle': 100000000,
		'base_resource_usage_per_cycle': 500000,
		'base_power': 10000000,
	},
]
var current_level = levels[0]

var building_name = 'Coal Powerplant'
var description = 'The best kind of power plant there is.'
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
			'type': Global.StatType.POLLUTION,
			'value': str(get_pollution_per_cycle()),
		},
		{
			'type': Global.StatType.USAGE,
			'value': str(get_resource_usage_per_cycle()),
		},
		{
			'type': Global.StatType.POWER,
			'value': str(get_power_generation()),
		},
	]


func get_pollution_per_cycle():
	return current_level['base_pollution_per_cycle']


func get_resource_usage_per_cycle():
	return current_level['base_resource_usage_per_cycle']


func get_power_generation():
	return current_level['base_power']


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade powerplant to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times.',
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
			emit_signal("info_updated", self, 'power')


func _on_cycle_timer_timeout():
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())


func notify_update(item):
	pass
