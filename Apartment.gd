extends 'Building.gd'
tool

const type := Global.BuildingType.APARTMENT_BUILDING
const effects := [Global.StatType.POPULATION_CAP]

var building_name = 'Apartment Building'
var description = 'Provides housing for the ultimate pollution producers: people.'

func init(world):
	.init(world)
	
	update_upgrade_label()
	update_recruiter_action()
	add_upgrade_action(level, levels)
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.POPULATION_CAP, get_population_cap())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func init_data():
	levels = [
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
			'base_population_cap': 200000000,
		},
		{
			'number': 9,
			'description': 'Colossal apartment building.',
			'base_population_cap': 1000000000,
		},
	]
	current_level = levels[0]


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_population_cap()),
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
	return $actions.get_children()


func post_level_upgrade():
	emit_signal("info_updated", self, Global.StatType.POPULATION_CAP, get_population_cap())


func perform_action(action, count):
	if action.name.begins_with("level"):
		perform_level_upgrade(action)
		return
	
	match action.name:
		'recruiter':
			world.hire_recruiter(count)
			action.price = world.get_recruiter_price()


func update_recruiter_action():
	$actions/recruiter.description = 'Hire a recruiter to help you get more people into your planet paradise. Each recruiter recruits one person per cycle. Recruiters are shared between all apartment buildings. Current recruiters in the world: ' + str(world.recruiters)
	$actions/recruiter.price = world.get_recruiter_price()


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_upgrade_label()
	if item == Global.StatType.RECRUITERS:
		update_recruiter_action()
