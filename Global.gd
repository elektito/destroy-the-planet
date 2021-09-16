class_name Global

const SETTINGS_FILE := 'settings.json'

enum StatType {
	LEVEL,
	POLLUTION,
	POLLUTION_PER_CYCLE,
	RESOURCES,
	RESOURCE_USAGE_PER_CYCLE,
	MONEY,
	MONEY_PER_CYCLE,
	PROFIT,
	ADS,
	POWER,
	MINING,
	POPULATION,
	POPULATION_CAP,
	POPULATION_INCREASE_PER_CYCLE,
	REACH,
	RECRUITERS,
}

enum BuildingType {
	FACTORY,
	POWERPLANT,
	MINE,
	APARTMENT_BUILDING,
	BAR,
}


static func get_building_types():
	return [
		BuildingType.FACTORY,
		BuildingType.POWERPLANT,
		BuildingType.MINE,
		BuildingType.APARTMENT_BUILDING,
		BuildingType.BAR,
	]


static func get_building_name(building_type) -> String:
	var names = {
		BuildingType.FACTORY: 'Factory',
		BuildingType.POWERPLANT: 'Powerplant',
		BuildingType.MINE: 'Mine',
		BuildingType.APARTMENT_BUILDING: 'Apartment Building',
		BuildingType.BAR: 'Bar',
	}
	return names[building_type]


static func human_readable_money(value : int) -> String:
	var suffixes = ['K', 'M', 'B', 'T']
	var fvalue = float(value)
	var i = -1
	while fvalue >= 1000 and i < len(suffixes) - 1:
		fvalue /= 1000.0
		i += 1
	if i >= 0:
		var svalue : String = '%.1f' % fvalue
		if svalue.ends_with('.0'):
			svalue = svalue.substr(0, len(svalue) - 2)
		return svalue + suffixes[i]
	else:
		return str(value)


static func get_level_upgrade_stats(current_level, next_level):
	var stats = []
	var key_to_stat_type = {
		'base_profit_per_sale': StatType.PROFIT,
		'base_pollution_per_cycle': StatType.POLLUTION_PER_CYCLE,
		'base_resource_usage_per_cycle': StatType.RESOURCE_USAGE_PER_CYCLE,
		'base_power': StatType.POWER,
		'base_ads': StatType.ADS,
		'base_population_increment': StatType.POPULATION_INCREASE_PER_CYCLE,
		'base_population_cap': StatType.POPULATION_CAP,
		'base_mining': StatType.MINING,
		'money_per_cycle': StatType.MONEY_PER_CYCLE,
	}
	for key in current_level:
		if key in key_to_stat_type:
			var multiplier = next_level[key] / current_level[key]
			if multiplier > 1:
				stats.append({
					'type': key_to_stat_type[key],
					'value': 'x' + str(multiplier),
				})
			elif multiplier == 1:
				var diff = int(next_level[key] - current_level[key])
				if diff > 0:
					stats.append({
						'type': key_to_stat_type[key],
						'value': '+' + str(diff),
					})
	return stats


static func get_all_node_children(node: Node) -> Array:
	var children := []
	for child in node.get_children():
		children.append(child)
		children.append_array(get_all_node_children(child))
	return children


static func save_settings():
	var master_bus = AudioServer.get_bus_index('Master')
	var sfx_bus = AudioServer.get_bus_index('SFX')
	var music_bus = AudioServer.get_bus_index('Music')
	
	var game_data = {
		'master_volume': db2linear(AudioServer.get_bus_volume_db(master_bus)),
		'sfx_volume': db2linear(AudioServer.get_bus_volume_db(sfx_bus)),
		'music_volume': db2linear(AudioServer.get_bus_volume_db(music_bus)),
		'fullscreen': OS.window_fullscreen,
	}
	var file = File.new()
	file.open(SETTINGS_FILE, File.WRITE)
	file.store_line(to_json(game_data))


static func load_settings():
	var master_bus = AudioServer.get_bus_index('Master')
	var sfx_bus = AudioServer.get_bus_index('SFX')
	var music_bus = AudioServer.get_bus_index('Music')
	
	var file = File.new()
	if not file.file_exists(SETTINGS_FILE):
		return
	file.open(SETTINGS_FILE, File.READ)
	var settings = parse_json(file.get_line())

	if 'master_volume' in settings:
		AudioServer.set_bus_volume_db(master_bus, linear2db(settings['master_volume']))
	if 'sfx_volume' in settings:
		AudioServer.set_bus_volume_db(sfx_bus, linear2db(settings['sfx_volume']))
	if 'music_volume' in settings:
		AudioServer.set_bus_volume_db(music_bus, linear2db(settings['music_volume']))
	if 'fullscreen' in settings:
		OS.window_fullscreen = settings['fullscreen']
