extends Node2D

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
var description = 'A good ol\' factory. Consumes some resources and pollutes a heck of a lot more.'
var level := 1

var world

var resource_usage = 1 setget set_resource_usage, get_resource_usage
var pollution = 5 setget set_pollution, get_pollution

func init(world):
	self.world = world


func set_resource_usage(value):
	# property can't be changed
	pass


func get_resource_usage():
	return 1


func set_pollution(value):
	# property can't be changed
	pass


func get_pollution():
	return 5


func get_stats():
	return [
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


func get_current_money_per_cycle():
	return current_level['base_money_per_cycle']


func get_current_pollution_per_cycle():
	return current_level['base_pollution_per_cycle']


func get_current_resource_usage_per_cycle():
	return current_level['base_resource_usage_per_cycle']


func get_actions():
	var actions = []
	if level < MAX_LEVEL:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade factory to level ' + str(level + 1) + '. Base resource usage will be twice the current amount and the pollution ten times.'
		})
	
	return actions


func perform_action(action):
	match action['name']:
		'level':
			level += 1


func _on_cycle_timer_timeout():
	world.produce_money(current_level['base_money_per_cycle'])
	world.produce_pollution(current_level['base_pollution_per_cycle'])
	world.consume_resources(current_level['base_resource_usage_per_cycle'])
