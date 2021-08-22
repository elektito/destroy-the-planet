extends Node2D

signal upgraded(building)
signal info_updated(building, item)

const type = Global.BuildingType.FACTORY

var levels = [
	{
		'number': 1,
		'description': 'Your rudimentary basic factory.',
		'base_money_per_cycle': 1,
		'base_pollution_per_cycle': 100,
		'base_resource_usage_per_cycle': 1,
	},
	{
		'number': 2,
		'description': 'Small factory.',
		'base_money_per_cycle': 10,
		'base_pollution_per_cycle': 1000,
		'base_resource_usage_per_cycle': 10,
	},
	{
		'number': 3,
		'description': 'Partially upgraded factory.',
		'base_money_per_cycle': 100,
		'base_pollution_per_cycle': 2000,
		'base_resource_usage_per_cycle': 100,
	},
	{
		'number': 4,
		'description': 'Medium-sized factory.',
		'base_money_per_cycle': 500,
		'base_pollution_per_cycle': 4000,
		'base_resource_usage_per_cycle': 500,
	},
	{
		'number': 5,
		'description': 'Above-medium factory.',
		'base_money_per_cycle': 1000,
		'base_pollution_per_cycle': 8000,
		'base_resource_usage_per_cycle': 1000,
	},
	{
		'number': 6,
		'description': 'Almost-there factory.',
		'base_money_per_cycle': 2000,
		'base_pollution_per_cycle': 16000,
		'base_resource_usage_per_cycle': 2000,
	},
	{
		'number': 7,
		'description': 'Beast of a factory.',
		'base_money_per_cycle': 10000,
		'base_pollution_per_cycle': 32000,
		'base_resource_usage_per_cycle': 4000,
	},
]
var current_level = levels[0]

var building_name = 'Factory'
var description = 'A good ol\' factory. Consumes some resources and pollutes a heck of a lot more, while also making money for you. Production will increase the more population, power production and mining you have.'
var level := 1

var world

func init(world):
	self.world = world
	$building.update_upgrade_label(self)


func get_stats():
	return [
		{
			'type': Global.StatType.LEVEL,
			'value': str(level),
		},
		{
			'type': Global.StatType.MONEY,
			'value': str(get_money_per_cycle()),
		},
		{
			'type': Global.StatType.POLLUTION,
			'value': str(get_pollution_per_cycle()),
		},
		{
			'type': Global.StatType.USAGE,
			'value': str(get_resource_usage_per_cycle()),
		},
	]


func get_demand_factor():
	var factor = world.get_demand()
	if factor == 0:
		factor = 1
	return factor


func get_power_factor():
	var factor = world.get_power()
	if factor == 0:
		factor = 1
	return factor


func get_mining_factor():
	var factor = world.get_mining()
	if factor == 0:
		factor = 1
	return factor


func get_money_per_cycle():
	return current_level['base_money_per_cycle'] * get_demand_factor() * get_power_factor() * get_mining_factor()


func get_pollution_per_cycle():
	return current_level['base_pollution_per_cycle'] * get_demand_factor() * get_power_factor() * get_mining_factor()


func get_resource_usage_per_cycle():
	return current_level['base_resource_usage_per_cycle'] * get_demand_factor() * get_power_factor() * get_mining_factor()


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		var next_level = levels[level] # level is one based, so levels[level] is next level
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade factory to level ' + str(level + 1) + '.',
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
			update_smoke()
			$building.update_upgrade_label(self)
		'cycle':
			_on_cycle_timer_timeout()


func _on_cycle_timer_timeout():
	world.produce_money(get_money_per_cycle())
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())


func notify_update(item):
	if item in ['demand', 'power', 'mining']:
		update_smoke()
		emit_signal("info_updated", self, 'money_per_cycle')
		emit_signal("info_updated", self, 'pollution_per_cycle')
		emit_signal("info_updated", self, 'resource_usage_per_cycle')
	if item == 'money':
		$building.update_upgrade_label(self)


func update_smoke():
	var max_demand_factor = 10
	var max_power_factor = 5000
	var max_mining_factor = 160
	var max_pollution = levels[-1]['base_pollution_per_cycle'] * max_demand_factor * max_power_factor * max_mining_factor
	var pollution = float(get_pollution_per_cycle())
	var rate = float(get_pollution_per_cycle()) / max_pollution
	if rate > 1.0:
		rate = 1.0
	rate = int(rate * 100)
	if rate == 0:
		rate = 1
	if rate != $smoke1.rate:
		$smoke1.rate = rate
		$smoke2.rate = rate
