extends 'Building.gd'
tool

const type := Global.BuildingType.APARTMENT_BUILDING
const effects := [Global.StatType.POPULATION_CAP]

var levels = [
	{
		'number': 1,
		'description': 'Tiny apartment building.',
		'base_population_cap': 100,
	},
	{
		'number': 2,
		'description': 'Small apartment building.',
		'base_population_cap': 5000,
	},
	{
		'number': 3,
		'description': 'Not quite medium apartment building.',
		'base_population_cap': 100000,
	},
	{
		'number': 4,
		'description': 'Medium-sized apartment building.',
		'base_population_cap': 500000,
	},
	{
		'number': 5,
		'description': 'Above-average apartment building',
		'base_population_cap': 5000000,
	},
	{
		'number': 6,
		'description': 'Big apartment building.',
		'base_population_cap': 10000000,
	},
	{
		'number': 7,
		'description': 'Huge apartment building.',
		'base_population_cap': 50000000,
	},
	{
		'number': 8,
		'description': 'Gigantic apartment building.',
		'base_population_cap': 100000000,
	},
	{
		'number': 9,
		'description': 'Colossal apartment building.',
		'base_population_cap': 1000000000,
	},
]
var current_level = levels[0]

var building_name = 'Apartment Building'
var description = 'Provides housing for the ultimate resource users and pollution producers: people.'
var level := 1

var world

func init(_world):
	world = _world
	update_upgrade_label(self)
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.POPULATION_CAP, get_population_cap())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func get_stats():
	return [
		{
			'type': Global.StatType.POPULATION_CAP,
			'value': str(get_population_cap()),
		},
	]


func get_population_cap():
	return current_level['base_population_cap']


func get_property(property):
	if property == Global.StatType.POPULATION_CAP:
		return get_population_cap()


func get_level_upgrade_price(level):
	if level < 8:
		return int(pow(100, level))
	else:
		return int(pow(100, 7)) * int(pow(2, level - 7))


func get_actions():
	var actions = []
	if level < levels[-1]['number']:
		var next_level = levels[level] # level is one based, so levels[level] is next level
		actions.append({
			'name': 'level',
			'title': 'Upgrade to Level ' + str(level + 1),
			'description': 'Upgrade apartment building to level ' + str(level + 1) + '.',
			'price': get_level_upgrade_price(level),
			'stats': Global.get_level_upgrade_stats(current_level, next_level),
		})
	actions.append({
		'name': 'recruiter',
		'title': 'Hire Recruiter',
		'description': 'Hire a recruiter to help you get more people into your planet paradise. Each recruiter recruits one person per cycle. Recruiters are shared between all apartment buildings. Current recruiters in the world: ' + str(world.get_recruiter_count()),
		'price': world.get_recruiter_price(),
		'stats': [{
			'type': Global.StatType.POPULATION_INCREASE_PER_CYCLE,
			'value': '+1',
		}],
		'batch_enabled': true,
		'button_text': 'Hire',
	})
	
	return actions


func perform_action(action, count):
	match action['name']:
		'level':
			level += 1
			current_level = levels[level - 1]
			emit_signal("upgraded", self)
			emit_signal("info_updated", self, Global.StatType.POPULATION_CAP, get_population_cap())
			update_upgrade_label(self)
		'recruiter':
			world.hire_recruiter(count)


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_upgrade_label(self)
