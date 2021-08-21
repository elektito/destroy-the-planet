class_name Global

enum StatType {
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
