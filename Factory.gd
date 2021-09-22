extends 'Building.gd'
tool

const type = Global.BuildingType.FACTORY
const effects := [
	Global.StatType.MONEY_PER_CYCLE,
	Global.StatType.POLLUTION_PER_CYCLE,
]

var building_name = 'Factory'
var description = 'A good ol\' factory. Can potentially pollute a heck of a lot, while also making money for you. Profit per sale will increase the more power production and mining you have, while total sale depends on population and advertising.'

var updated_items = {}

func init(world):
	.init(world)
	supports_boost = true
	
	update_upgrade_label()
	add_upgrade_action(level, levels)
	
	update()
	
	world.connect("info_updated", self, "_on_world_info_updated")


func init_data():
	levels = [
		{
			'number': 1,
			'description': 'Your rudimentary basic factory.',
			'base_profit_per_sale': 1,
			'base_pollution_per_cycle': 10,
		},
		{
			'number': 2,
			'description': 'Small factory.',
			'base_profit_per_sale': 5,
			'base_pollution_per_cycle': 20,
		},
		{
			'number': 3,
			'description': 'Partially upgraded factory.',
			'base_profit_per_sale': 10,
			'base_pollution_per_cycle': 100,
		},
		{
			'number': 4,
			'description': 'Medium-sized factory.',
			'base_profit_per_sale': 20,
			'base_pollution_per_cycle': 200,
		},
		{
			'number': 5,
			'description': 'Above-medium factory.',
			'base_profit_per_sale': 80,
			'base_pollution_per_cycle': 400,
		},
		{
			'number': 6,
			'description': 'Almost-there factory.',
			'base_profit_per_sale': 160,
			'base_pollution_per_cycle': 800,
		},
		{
			'number': 7,
			'description': 'Beast of a factory.',
			'base_profit_per_sale': 800,
			'base_pollution_per_cycle': 1600,
		},
	]
	current_level = levels[0]


func get_stats():
	return [
		Global.new_stat(Global.StatType.LEVEL, level),
		Global.new_stat(Global.StatType.PROFIT, get_profit_per_sale()),
		Global.new_stat(Global.StatType.MONEY_PER_CYCLE, get_money_per_cycle()),
		Global.new_stat(Global.StatType.POLLUTION_PER_CYCLE, get_pollution_per_cycle()),
	]


func get_power_factor():
	var power = world.get_total_property(Global.StatType.POWER)
	return sqrt(power)


func get_mining_factor():
	var factor = world.get_total_property(Global.StatType.MINING)
	return factor


func get_boost_factor():
	return pow(5, boost)


func get_sales(population=null, reach=null):
	if population == null:
		population = world.get_population()
	if reach == null:
		reach = world.get_reach()
	return population * reach


func get_profit_per_sale():
	var performance_factor = get_mining_factor() + get_power_factor()
	return (current_level['base_profit_per_sale'] + performance_factor) * get_boost_factor()


func get_money_per_cycle():
	var result = get_profit_per_sale() * get_sales()
	if result < 1:
		result = 1
	return result


func get_pollution_per_cycle(population=null, reach=null, level_idx=null):
	var sales = get_sales(population, reach)
	var base_pollution_per_cycle := 0
	if level_idx == null:
		base_pollution_per_cycle = current_level['base_pollution_per_cycle']
	else:
		base_pollution_per_cycle = levels[level_idx]['base_pollution_per_cycle']
	return sales * base_pollution_per_cycle * get_boost_factor()


func get_property(property):
	match property:
		Global.StatType.MONEY_PER_CYCLE:
			return get_money_per_cycle()
		Global.StatType.POLLUTION_PER_CYCLE:
			return get_pollution_per_cycle()
		_:
			return 0


func get_actions():
	return $actions.get_children()


func update():
	emit_signal("info_updated", self, Global.StatType.PROFIT, get_profit_per_sale())
	emit_signal("info_updated", self, Global.StatType.POLLUTION_PER_CYCLE, get_pollution_per_cycle())
	emit_signal("info_updated", self, Global.StatType.MONEY_PER_CYCLE, get_money_per_cycle())
	
	update_smoke()


func post_level_upgrade():
	update()


func perform_action(action, _count):
	if action.name.begins_with("level"):
		perform_level_upgrade(action)
		return
	
	match action.name:
		'cycle':
			_on_cycle_timer_timeout()


func _process(_delta):
	var interesting = [
		Global.StatType.ADS,
		Global.StatType.POWER,
		Global.StatType.MINING,
		Global.StatType.POPULATION,
	]
	var something_interesting_changed = false
	for item in updated_items.keys():
		if item in interesting:
			something_interesting_changed = true
		if item == Global.StatType.MONEY:
			update_upgrade_label()
	if something_interesting_changed:
		var money_per_cycle = get_money_per_cycle()
		var pollution_per_cycle = get_pollution_per_cycle()
		update()
		$actions/cycle.description = 'Manually perform one cycle of building operation by clicking the button. This generates $%s of money and %s tons of pollution.' % [Global.human_readable(money_per_cycle), Global.human_readable(pollution_per_cycle)]
	updated_items = {}


func _boost_changed():
	update()


func _on_cycle_timer_timeout():
	if decorative or operations_paused:
		return
	world.produce_money(get_money_per_cycle())
	world.produce_pollution(get_pollution_per_cycle())


func _on_world_info_updated(_world, item, _value):
	updated_items[item] = true


func update_smoke():
	var population = 3000000000
	var reach = 0.18
	var max_pollution = get_pollution_per_cycle(population, reach, -1)
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
