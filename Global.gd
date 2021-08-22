class_name Global

enum StatType {
	LEVEL,
	POLLUTION,
	USAGE,
	MONEY,
	ENTERTAINMENT,
	POWER,
	MINING,
	POPULATION_CAP,
	POPULATION_INCREASE,
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
		'base_money_per_cycle': StatType.MONEY,
		'base_pollution_per_cycle': StatType.POLLUTION,
		'base_resource_usage_per_cycle': StatType.USAGE,
		'base_power': StatType.POWER,
		'base_entertainment': StatType.ENTERTAINMENT,
		'base_population_increment': StatType.POPULATION_INCREASE,
		'base_population_cap': StatType.POPULATION_CAP,
		'base_mining': StatType.MINING,
	}
	for key in current_level:
		if key in key_to_stat_type:
			var multiplier = next_level[key] / current_level[key]
			if multiplier != 1:
				stats.append({
					'type': key_to_stat_type[key],
					'value': 'x' + str(multiplier),
				})
	return stats
