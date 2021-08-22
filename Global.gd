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
	var suffixes = ['K', 'M', 'B', 'T', 'QA', 'QI', 'SX', 'SP', 'OC', 'NN']
	var fvalue = float(value)
	var i = -1
	while fvalue >= 1000 and i < len(suffixes):
		fvalue /= 1000.0
		i += 1
	if i >= 0:
		var svalue : String = '%.1f' % fvalue
		if svalue.ends_with('.0'):
			svalue = svalue.substr(0, len(svalue) - 2)
		return svalue + suffixes[i]
	else:
		return str(value)
