extends 'Building.gd'
tool

const type := Global.BuildingType.MINE
const effects := [
	Global.StatType.RESOURCE_USAGE_PER_CYCLE,
	Global.StatType.POLLUTION_PER_CYCLE,
	Global.StatType.MINING,
]

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
	add_upgrade_action(level, levels)
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.MINING, get_mining())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_pollution_per_cycle()),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_resource_usage_per_cycle()),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_mining()),
	]


func get_pollution_per_cycle():
	return current_level['base_pollution_per_cycle']


func get_resource_usage_per_cycle():
	return 0


func get_mining():
	return current_level['base_mining']


func get_property(property):
	match property:
		Global.StatType.MINING:
			return get_mining()
		Global.StatType.POLLUTION_PER_CYCLE:
			return get_pollution_per_cycle()
		Global.StatType.RESOURCE_USAGE_PER_CYCLE:
			return get_resource_usage_per_cycle()
		_:
			return 0


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
			
			emit_signal("info_updated", self, Global.StatType.MINING, get_mining())
		
		update_upgrade_label(self)
		emit_signal("info_updated", self, Global.StatType.LEVEL, level)
		emit_signal("info_updated", self, Global.StatType.ACTIONS, get_actions())
		
		return
	
	match action['name']:
		'cycle':
			_on_cycle_timer_timeout()


func _on_cycle_timer_timeout():
	if decorative or operations_paused:
		return
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_upgrade_label(self)
