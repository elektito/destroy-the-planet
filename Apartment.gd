extends Node2D

signal upgraded(building)
signal info_updated(building, item)

const type := Global.BuildingType.APARTMENT_BUILDING

var levels = [
	{
		'number': 1,
		'description': 'Tiny apartment building.',
		'base_population_increment': 1,
		'base_population_cap': 100,
	},
	{
		'number': 2,
		'description': 'Small apartment building.',
		'base_population_increment': 10,
		'base_population_cap': 1000,
	},
	{
		'number': 3,
		'description': 'Not quite medium apartment building.',
		'base_population_increment': 100,
		'base_population_cap': 100000,
	},
	{
		'number': 4,
		'description': 'Medium-sized apartment building.',
		'base_population_increment': 1000,
		'base_population_cap': 1000000,
	},
	{
		'number': 5,
		'description': 'Above-average apartment building',
		'base_population_increment': 10000,
		'base_population_cap': 1000000,
	},
	{
		'number': 6,
		'description': 'Big apartment building.',
		'base_population_increment': 100000,
		'base_population_cap': 10000000,
	},
	{
		'number': 7,
		'description': 'Huge apartment building.',
		'base_population_increment': 1000000,
		'base_population_cap': 100000000,
	},
	{
		'number': 8,
		'description': 'Gigantic apartment building.',
		'base_population_increment': 10000000,
		'base_population_cap': 1000000000,
	},
	{
		'number': 9,
		'description': 'Colossal apartment building.',
		'base_population_increment': 100000000,
		'base_population_cap': 10000000000,
	},
]
var current_level = levels[0]

var building_name = 'Apartment Building'
var description = 'Provides housing for the ultimate resource users and pollution producers: people.'
var level := 1

var world

func init(world):
	self.world = world


func get_stats():
	return [
		{
			'type': Global.StatType.POPULATION_CAP,
			'value': str(get_population_cap()),
		},
		{
			'type': Global.StatType.POPULATION_INCREASE,
			'value': str(get_population_increment()),
		},
	]


func get_population_increment():
	return current_level['base_population_increment']


func get_population_cap():
	return current_level['base_population_cap']


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade apartment building to level ' + str(level + 1) + '.',
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
			emit_signal("info_updated", self, "population_cap")
			emit_signal("info_updated", self, "population_increment")


func _on_cycle_timer_timeout():
	world.add_population(get_population_increment())


func notify_update(item):
	pass
