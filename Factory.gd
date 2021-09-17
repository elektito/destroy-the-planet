extends 'Building.gd'
tool

const type = Global.BuildingType.FACTORY
const effects := [
	Global.StatType.MONEY_PER_CYCLE,
	Global.StatType.RESOURCE_USAGE_PER_CYCLE,
	Global.StatType.POLLUTION_PER_CYCLE,
]

var building_name = 'Factory'
var description = 'A good ol\' factory. Consumes some resources and pollutes a heck of a lot more, while also making money for you. Profit per sale will increase the more power production and mining you have, while total sale depends on population and advertising.'

func init(world):
	.init(world)
	
	update_upgrade_label()
	update_smoke()
	add_upgrade_action(level, levels)
	
	# emit these signals so that anyone interested can update iteself
	emit_signal("info_updated", self, Global.StatType.PROFIT, get_profit_per_sale())
	emit_signal("info_updated", self, Global.StatType.MONEY_PER_CYCLE, get_money_per_cycle())
	emit_signal("info_updated", self, Global.StatType.POLLUTION_PER_CYCLE, get_pollution_per_cycle())
	emit_signal("info_updated", self, Global.StatType.RESOURCE_USAGE_PER_CYCLE, get_resource_usage_per_cycle())
	
	world.connect("info_updated", self, "_on_world_info_updated")


func init_data():
	levels = [
		{
			'number': 1,
			'description': 'Your rudimentary basic factory.',
			'base_profit_per_sale': 1,
			'base_pollution_per_cycle': 100,
			'base_resource_usage_per_cycle': 1,
		},
		{
			'number': 2,
			'description': 'Small factory.',
			'base_profit_per_sale': 5,
			'base_pollution_per_cycle': 1000,
			'base_resource_usage_per_cycle': 10,
		},
		{
			'number': 3,
			'description': 'Partially upgraded factory.',
			'base_profit_per_sale': 10,
			'base_pollution_per_cycle': 2000,
			'base_resource_usage_per_cycle': 100,
		},
		{
			'number': 4,
			'description': 'Medium-sized factory.',
			'base_profit_per_sale': 20,
			'base_pollution_per_cycle': 4000,
			'base_resource_usage_per_cycle': 500,
		},
		{
			'number': 5,
			'description': 'Above-medium factory.',
			'base_profit_per_sale': 40,
			'base_pollution_per_cycle': 8000,
			'base_resource_usage_per_cycle': 1000,
		},
		{
			'number': 6,
			'description': 'Almost-there factory.',
			'base_profit_per_sale': 80,
			'base_pollution_per_cycle': 16000,
			'base_resource_usage_per_cycle': 2000,
		},
		{
			'number': 7,
			'description': 'Beast of a factory.',
			'base_profit_per_sale': 160,
			'base_pollution_per_cycle': 32000,
			'base_resource_usage_per_cycle': 4000,
		},
	]
	current_level = levels[0]


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.PROFIT, get_profit_per_sale()),
		Global.new_stat(Global.StatType.MONEY_PER_CYCLE, get_money_per_cycle()),
		Global.new_stat(Global.StatType.POLLUTION_PER_CYCLE, get_pollution_per_cycle()),
		Global.new_stat(Global.StatType.RESOURCE_USAGE_PER_CYCLE, get_resource_usage_per_cycle()),
	]


func get_power_factor():
	var power = world.get_total_property(Global.StatType.POWER)
	var factor := 0
	var counter = 0
	var next_level = 10
	var step = 1
	while counter < power:
		factor += 1
		counter += step
		if counter >= next_level:
			step += next_level / 10
			next_level *= 10
	return factor


func get_mining_factor():
	var factor = world.get_total_property(Global.StatType.MINING)
	return factor


func get_sales(population=null, reach=null):
	if population == null:
		population = world.get_population()
	if reach == null:
		reach = world.get_reach()
	return population * reach


func get_profit_per_sale():
	var performance_factor = get_mining_factor() + get_power_factor()
	return current_level['base_profit_per_sale'] + performance_factor


func get_money_per_cycle():
	var result = get_profit_per_sale() * get_sales()
	if result < 1:
		result = 1
	return result


func get_pollution_per_cycle(population=null, reach=null):
	var sales = get_sales(population, reach)
	return sales * 3


func get_resource_usage_per_cycle():
	return 0


func get_property(property):
	match property:
		Global.StatType.MONEY_PER_CYCLE:
			return get_money_per_cycle()
		Global.StatType.POLLUTION_PER_CYCLE:
			return get_pollution_per_cycle()
		Global.StatType.RESOURCE_USAGE_PER_CYCLE:
			return get_resource_usage_per_cycle()
		_:
			return 0


func get_actions():
	return $actions.get_children()


func post_level_upgrade():
	emit_signal("info_updated", self, Global.StatType.PROFIT, get_profit_per_sale())
	emit_signal("info_updated", self, Global.StatType.MONEY_PER_CYCLE, get_money_per_cycle())
	emit_signal("info_updated", self, Global.StatType.RESOURCE_USAGE_PER_CYCLE, get_resource_usage_per_cycle())
	emit_signal("info_updated", self, Global.StatType.MONEY_PER_CYCLE, get_money_per_cycle())
	
	update_smoke()


func perform_action(action, _count):
	if action.name.begins_with("level"):
		perform_level_upgrade(action)
		return
	
	match action.name:
		'cycle':
			_on_cycle_timer_timeout()


func _on_cycle_timer_timeout():
	if decorative or operations_paused:
		return
	world.produce_money(get_money_per_cycle())
	world.produce_pollution(get_pollution_per_cycle())
	world.consume_resources(get_resource_usage_per_cycle())


func _on_world_info_updated(_world, item, _value):
	var interesting = [
		Global.StatType.ADS,
		Global.StatType.POWER,
		Global.StatType.MINING,
		Global.StatType.POPULATION,
	]
	if item in interesting:
		update_smoke()
		emit_signal("info_updated", self, Global.StatType.PROFIT, get_profit_per_sale())
		emit_signal("info_updated", self, Global.StatType.MONEY_PER_CYCLE, get_money_per_cycle())
		emit_signal("info_updated", self, Global.StatType.POLLUTION_PER_CYCLE, get_pollution_per_cycle())
		emit_signal("info_updated", self, Global.StatType.RESOURCE_USAGE_PER_CYCLE, get_resource_usage_per_cycle())
	if item == Global.StatType.MONEY:
		update_upgrade_label()


func update_smoke():
	var population = 3000000000
	var reach = 0.18
	var max_pollution = get_pollution_per_cycle(population, reach)
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
