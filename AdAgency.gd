extends 'Building.gd'
tool

const type := Global.BuildingType.AD_AGENCY
const effects := [Global.StatType.ADS]

var building_name = 'Ad Agency'
var description = 'Pumping ads 24/7 towards the populace. Guaranteed to increase sales.'

func init(world):
	.init(world)
	
	update_upgrade_label()
	add_upgrade_action(level, levels)
	
	# notify any interested listeners that there might be some changes
	emit_signal("info_updated", self, Global.StatType.ADS, get_ads())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func init_data():
	levels = [
		{
			'number': 1,
			'description': 'Level 1 ad agency.',
			'base_ads': 1,
		},
		{
			'number': 2,
			'description': 'Level 2 ad agency.',
			'base_ads': 2,
		},
		{
			'number': 3,
			'description': 'Level 3 ad agency.',
			'base_ads': 3,
		},
		{
			'number': 4,
			'description': 'Level 4 ad agency.',
			'base_ads': 4,
		},
		{
			'number': 5,
			'description': 'Level 5 ad agency.',
			'base_ads': 5,
		},
		{
			'number': 6,
			'description': 'Level 6 ad agency.',
			'base_ads': 6,
		},
		{
			'number': 7,
			'description': 'Level 7 ad agency.',
			'base_ads': 7,
		},
	]
	current_level = levels[0]


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.POPULATION_CAP, get_ads()),
	]


func get_ads():
	return current_level['base_ads']


func get_property(property):
	if property == Global.StatType.ADS:
		return get_ads()


func get_actions():
	return $actions.get_children()


func post_level_upgrade():
	emit_signal("info_updated", self, Global.StatType.ADS, get_ads())


func perform_action(action, _count):
	if action.name.begins_with("level"):
		perform_level_upgrade(action)
		return


func _on_world_info_updated(_world, item, _value):
	if item == Global.StatType.MONEY:
		update_upgrade_label()
