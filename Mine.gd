extends Node2D

signal upgraded(building)

const type := Global.BuildingType.MINE

var levels = [
	{
		'number': 1,
		'description': 'Tiny mine.',
		'base_pollution_per_cycle': 1,
		'base_resource_usage_per_cycle': 100,
		'base_mining': 1000,
	},
	{
		'number': 2,
		'description': 'Small mine.',
		'base_pollution_per_cycle': 10,
		'base_resource_usage_per_cycle': 10000,
		'base_mining': 2000,
	},
	{
		'number': 3,
		'description': 'Partially upgraded mine.',
		'base_pollution_per_cycle': 100,
		'base_resource_usage_per_cycle': 100000,
		'base_mining': 4000,
	},
	{
		'number': 4,
		'description': 'Medium-sized mine.',
		'base_pollution_per_cycle': 500,
		'base_resource_usage_per_cycle': 1000000,
		'base_mining': 8000,
	},
	{
		'number': 5,
		'description': 'Big mine.',
		'base_pollution_per_cycle': 1000,
		'base_resource_usage_per_cycle': 10000000,
		'base_mining': 16000,
	},
]
var current_level = levels[0]

var building_name = 'Mine'
var description = 'Mines resource from the planet, accelerating certain doom.'
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
			'type': Global.StatType.MINING,
			'value': str(get_mining()),
		},
	]


func get_pollution_per_cycle():
	return current_level['base_pollution_per_cycle']


func get_resource_usage_per_cycle():
	return current_level['base_resource_usage_per_cycle']


func get_mining():
	return current_level['base_mining']


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade mine to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times.',
			'price': (level + 1) * 1000,
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
			current_level = levels[level - 1]
			emit_signal("upgraded", self)


func _on_cycle_timer_timeout():
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())
