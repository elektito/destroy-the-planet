extends 'Building.gd'
tool

const type := Global.BuildingType.POWERPLANT
const effects := [
	Global.StatType.POWER,
	Global.StatType.POLLUTION_PER_CYCLE,
]

var building_name = 'Coal Powerplant'
var description = 'The best kind of power plant there is.'

func init(world):
	.init(world)
	
	update_upgrade_label()
	add_upgrade_action(level, levels)
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.POWER, get_power_generation())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func init_data():
	levels = [
		{
			'number': 1,
			'description': 'Tiny powerplant.',
			'base_pollution_per_cycle': 1562500000,
			'base_power': 2,
		},
		{
			'number': 2,
			'description': 'Small powerplant.',
			'base_pollution_per_cycle': 3125000000,
			'base_power': 10,
		},
		{
			'number': 3,
			'description': 'Not quite medium powerplant.',
			'base_pollution_per_cycle': 6250000000,
			'base_power': 25,
		},
		{
			'number': 4,
			'description': 'Medium-sized powerplant.',
			'base_pollution_per_cycle': 12500000000,
			'base_power': 125,
		},
		{
			'number': 5,
			'description': 'Above-medium powerplant.',
			'base_pollution_per_cycle': 25000000000,
			'base_power': 500,
		},
		{
			'number': 6,
			'description': 'Big powerplant.',
			'base_pollution_per_cycle': 50000000000,
			'base_power': 2000,
		},
		{
			'number': 7,
			'description': 'Huge powerplant.',
			'base_pollution_per_cycle': 100000000000,
			'base_power': 16000,
		},
		{
			'number': 8,
			'description': 'Gigantic powerplant.',
			'base_pollution_per_cycle': 200000000000,
			'base_power': 48000,
		},
	]
	current_level = levels[0]


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.POLLUTION_PER_CYCLE, get_pollution_per_cycle()),
		Global.new_stat(Global.StatType.POWER, get_power_generation()),
	]


func get_pollution_per_cycle():
	return current_level['base_pollution_per_cycle']


func get_power_generation():
	return current_level['base_power']


func get_property(property):
	match property:
		Global.StatType.POWER:
			return get_power_generation()
		Global.StatType.POLLUTION_PER_CYCLE:
			return get_pollution_per_cycle()


func get_actions():
	return $actions.get_children()


func post_level_upgrade():
	emit_signal("info_updated", self, Global.StatType.POWER, get_power_generation())
	emit_signal("info_updated", self, Global.StatType.POLLUTION_PER_CYCLE, get_pollution_per_cycle())
	update_smoke()


func perform_action(action, _count):
	if action.name.begins_with("level"):
		perform_level_upgrade(action)
		return


func _on_cycle_timer_timeout():
	if decorative or operations_paused:
		return
	world.produce_pollution(get_pollution_per_cycle())


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_upgrade_label()


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
