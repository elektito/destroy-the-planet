extends 'Building.gd'
tool

const type := Global.BuildingType.MINE

var levels = [
	{
		'number': 1,
		'description': 'Tiny mine.',
		'base_pollution_per_cycle': 1,
		'base_resource_usage_per_cycle': 100,
		'base_mining': 2,
	},
	{
		'number': 2,
		'description': 'Small mine.',
		'base_pollution_per_cycle': 10,
		'base_resource_usage_per_cycle': 10000,
		'base_mining': 4,
	},
	{
		'number': 3,
		'description': 'Partially upgraded mine.',
		'base_pollution_per_cycle': 100,
		'base_resource_usage_per_cycle': 50000,
		'base_mining': 8,
	},
	{
		'number': 4,
		'description': 'Medium-sized mine.',
		'base_pollution_per_cycle': 500,
		'base_resource_usage_per_cycle': 100000,
		'base_mining': 16,
	},
	{
		'number': 5,
		'description': 'Big mine.',
		'base_pollution_per_cycle': 1000,
		'base_resource_usage_per_cycle': 200000,
		'base_mining': 32,
	},
]
var current_level = levels[0]

var building_name = 'Mine'
var description = 'Mines resource from the planet, accelerating certain doom.'
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
			'type': Global.StatType.POLLUTION_PER_CYCLE,
			'value': str(get_pollution_per_cycle()),
		},
		{
			'type': Global.StatType.RESOURCE_USAGE_PER_CYCLE,
			'value': str(get_resource_usage_per_cycle()),
		},
		{
			'type': Global.StatType.MINING,
			'value': str(get_mining()),
		},
	]


func get_pollution_per_cycle():
	return current_level['base_pollution_per_cycle']


func get_demand_factor():
	var factor = world.get_demand() * 10
	if factor == 0:
		factor = 1
	return factor


func get_power_factor():
	var factor = world.get_power()
	if factor == 0:
		factor = 1
	return factor


func get_resource_usage_per_cycle():
	return current_level['base_resource_usage_per_cycle'] * get_demand_factor() * get_power_factor()


func get_mining():
	return current_level['base_mining']


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		var next_level = levels[level] # level is one based, so levels[level] is next level
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade mine to level ' + str(level + 1) + '.',
			'price': int(pow(100, level)),
			'stats': Global.get_level_upgrade_stats(current_level, next_level),
		})
	
	actions.append({
		'name': 'cycle',
		'title': 'Manual Cycle',
		'description': 'Manually perform one cycle of building operation by clicking the button.',
		'price': 0,
		'stats': [],
		'button_text': 'Perform',
	})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1
			current_level = levels[level - 1]
			emit_signal("upgraded", self)
			emit_signal("info_updated", self, Global.StatType.MINING, get_mining())
			update_upgrade_label(self)
		'cycle':
			_on_cycle_timer_timeout()


func _on_cycle_timer_timeout():
	if decorative or operations_paused:
		return
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())


func notify_update(item):
	if item == Global.StatType.MONEY:
		update_upgrade_label(self)
