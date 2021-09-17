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
	add_upgrade_action(level, levels)
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.POWER, get_power_generation())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_pollution_per_cycle()),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_resource_usage_per_cycle()),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_power_generation()),
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
	return $actions.get_children()


func perform_action(action, _count):
	if action.name.begins_with("level"):
		# just remove the child from the list. the widget will free it later.
		$actions.remove_child(action)
		print('action %s removed from tree' % action.name)
		
		level += 1
		current_level = levels[level - 1]
		if level < len(levels):
			add_upgrade_action(level, levels)
			
			emit_signal("upgraded", self)
			
			emit_signal("info_updated", self, Global.StatType.POWER, get_power_generation())
			
			update_smoke()
		
		update_upgrade_label(self)
		emit_signal("info_updated", self, Global.StatType.LEVEL, level)
		emit_signal("info_updated", self, Global.StatType.ACTIONS, get_actions())
		
		return


func _on_cycle_timer_timeout():
	if decorative or operations_paused:
		return
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())


func _on_world_info_updated(_world, item, _value):
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
