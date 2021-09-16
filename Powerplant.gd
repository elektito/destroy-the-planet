extends 'Building.gd'
tool

const type := Global.BuildingType.POWERPLANT
const effects := [
	Global.StatType.POWER,
	Global.StatType.POLLUTION_PER_CYCLE,
	Global.StatType.RESOURCE_USAGE_PER_CYCLE,
]

var levels = [
	{
		'number': 1,
		'description': 'Tiny powerplant.',
		'base_pollution_per_cycle': 10,
		'base_resource_usage_per_cycle': 1,
		'base_power': 2,
	},
	{
		'number': 2,
		'description': 'Small powerplant.',
		'base_pollution_per_cycle': 20,
		'base_resource_usage_per_cycle': 5,
		'base_power': 10,
	},
	{
		'number': 3,
		'description': 'Not quite medium powerplant.',
		'base_pollution_per_cycle': 40,
		'base_resource_usage_per_cycle': 10,
		'base_power': 20,
	},
	{
		'number': 4,
		'description': 'Medium-sized powerplant.',
		'base_pollution_per_cycle': 80,
		'base_resource_usage_per_cycle': 20,
		'base_power': 80,
	},
	{
		'number': 5,
		'base_pollution_per_cycle': 400,
		'base_resource_usage_per_cycle': 100,
		'base_power': 160,
	},
	{
		'number': 6,
		'description': 'Big powerplant.',
		'base_pollution_per_cycle': 2000,
		'base_resource_usage_per_cycle': 200,
		'base_power': 800,
	},
	{
		'number': 7,
		'description': 'Huge powerplant.',
		'base_pollution_per_cycle': 4000,
		'base_resource_usage_per_cycle': 400,
		'base_power': 1600,
	},
	{
		'number': 8,
		'description': 'Gigantic powerplant.',
		'base_pollution_per_cycle': 20000,
		'base_resource_usage_per_cycle': 800,
		'base_power': 3200,
	},
]
var current_level = levels[0]

var building_name = 'Coal Powerplant'
var description = 'The best kind of power plant there is.'
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


func get_property(property):
	match property:
		Global.StatType.POWER:
			return get_power_generation()
		Global.StatType.POLLUTION_PER_CYCLE:
			return get_pollution_per_cycle()
		Global.StatType.RESOURCE_USAGE_PER_CYCLE:
			return get_resource_usage_per_cycle()


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		var next_level = levels[level] # level is one based, so levels[level] is next level
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade powerplant to level ' + str(level + 1) + '.',
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
			emit_signal("info_updated", self, Global.StatType.POWER, get_power_generation())
			update_smoke()
			update_upgrade_label(self)


func _on_cycle_timer_timeout():
	if decorative or operations_paused:
		return
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())


func notify_update(item):
	if item == Global.StatType.MONEY:
		update_upgrade_label(self)


func update_smoke():
	var max_pollution = levels[-1]['base_pollution_per_cycle']
	var rate = float(get_pollution_per_cycle()) / max_pollution
	if rate > 1.0:
		rate = 1.0
	
	# use sqrt so that growth is fast at the beginning, but becomes slower as we
	# approach one
	rate = sqrt(rate)
	
	rate = int(rate * 100)
	if rate == 0:
		rate = 1
	set_smoke_rate(rate)
