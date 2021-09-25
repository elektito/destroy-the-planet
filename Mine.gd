extends 'Building.gd'
tool

const type := Global.BuildingType.MINE
const effects := [
	Global.StatType.MINING,
]

var building_name = 'Mine'
var description = 'Mines resources from the planet, accelerating certain doom.'

func init(world):
	.init(world)
	
	supports_boost = true
	
	update_upgrade_label()
	add_upgrade_action(level, levels)
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.MINING, get_mining())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func init_data():
	levels = [
		{
			'number': 1,
			'description': 'Tiny mine.',
			'base_mining': 2,
		},
		{
			'number': 2,
			'description': 'Small mine.',
			'base_mining': 4,
		},
		{
			'number': 3,
			'description': 'Partially upgraded mine.',
			'base_mining': 8,
		},
		{
			'number': 4,
			'description': 'Medium-sized mine.',
			'base_mining': 40,
		},
		{
			'number': 5,
			'description': 'Big mine.',
			'base_mining': 200,
		},
	]
	current_level = levels[0]


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.MINING, get_mining()),
	]


func get_boost_factor():
	return pow(3, boost)


func get_mining():
	return current_level['base_mining'] * get_boost_factor()


func get_property(property):
	match property:
		Global.StatType.MINING:
			return get_mining()
		_:
			return 0


func get_actions():
	return $actions.get_children()


func update():
	emit_signal("info_updated", self, Global.StatType.MINING, get_mining())


func post_level_upgrade():
	update()


func perform_action(action, _count):
	if action.name == 'level_upgrade':
		set_level(level + 1)
		return


func _boost_changed():
	update()


func _serialize():
	return {}


func _deserialize(_data):
	update()


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_upgrade_label()
