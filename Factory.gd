extends Node2D

signal upgraded(building)

const type = Global.BuildingType.FACTORY
const MAX_LEVEL := 7

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
		'base_pollution_per_cycle': 10000,
		'base_resource_usage_per_cycle': 10,
	},
	{
		'number': 3,
		'description': 'Partially upgraded factory.',
		'base_money_per_cycle': 100,
		'base_pollution_per_cycle': 100000,
		'base_resource_usage_per_cycle': 100,
	},
	{
		'number': 4,
		'description': 'Medium-sized factory.',
		'base_money_per_cycle': 1000,
		'base_pollution_per_cycle': 1000000,
		'base_resource_usage_per_cycle': 500,
	},
	{
		'number': 5,
		'description': 'Above-medium factory.',
		'base_money_per_cycle': 10000,
		'base_pollution_per_cycle': 10000000,
		'base_resource_usage_per_cycle': 1000,
	},
	{
		'number': 6,
		'description': 'Almost-there factory.',
		'base_money_per_cycle': 100000,
		'base_pollution_per_cycle': 100000000,
		'base_resource_usage_per_cycle': 10000,
	},
	{
		'number': 7,
		'description': 'Beast of a factory.',
		'base_money_per_cycle': 100000,
		'base_pollution_per_cycle': 100000000,
		'base_resource_usage_per_cycle': 50000,
	},
]
var current_level = levels[0]

var building_name = 'Factory'
var description = 'A good ol\' factory. Consumes some resources and pollutes a heck of a lot more, while also making money for you. Production will increase the more population, power production and mining you have.'
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
			'type': Global.StatType.MONEY,
			'value': str(get_current_money_per_cycle()),
		},
		{
			'type': Global.StatType.POLLUTION,
			'value': str(get_current_pollution_per_cycle()),
		},
		{
			'type': Global.StatType.USAGE,
			'value': str(get_current_resource_usage_per_cycle()),
		},
	]


func get_population_factor():
	var factor = world.get_population() / 1000000
	if factor == 0:
		factor = 1
	return factor


func get_power_factor():
	var factor = world.get_power() / 1000000
	if factor == 0:
		factor = 1
	return factor


func get_mining_factor():
	var factor = world.get_mining() / 1000000
	if factor == 0:
		factor = 1
	return factor


func get_current_money_per_cycle():
	return current_level['base_money_per_cycle'] * get_population_factor() * get_power_factor() * get_mining_factor()


func get_current_pollution_per_cycle():
	return current_level['base_pollution_per_cycle'] * get_population_factor() * get_power_factor() * get_mining_factor()


func get_current_resource_usage_per_cycle():
	return current_level['base_resource_usage_per_cycle'] * get_population_factor() * get_power_factor() * get_mining_factor()


func get_actions():
	var actions = []
	if level < MAX_LEVEL:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade factory to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times.',
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
	world.produce_money(current_level['base_money_per_cycle'])
	world.produce_pollution(current_level['base_pollution_per_cycle'])
	world.consume_resources(current_level['base_resource_usage_per_cycle'])
