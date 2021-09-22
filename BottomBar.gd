extends PanelContainer

onready var population_value_label = $margin/hbox/population_value_label
onready var power_value_label = $margin/hbox/power_value_label
onready var mining_value_label = $margin/hbox/mining_value_label
onready var ads_value_label = $margin/hbox/ads_value_label
onready var reach_value_label = $margin/hbox/reach_value_label

var world
var world_updated := false

func init(_world):
	world = _world
	
	world.connect("info_updated", self, "_on_world_info_updated") # warning-ignore: return_value_discarded
	
	update()


func update():
	population_value_label.text = Global.human_readable(world.get_population()) + '/' + Global.human_readable(world.get_population_cap()) + ' (+' + Global.human_readable(world.get_population_increment_per_cycle()) + ')'
	power_value_label.text = str(world.get_total_property(Global.StatType.POWER))
	mining_value_label.text = str(world.get_total_property(Global.StatType.MINING))
	ads_value_label.text = Global.human_readable(world.get_total_property(Global.StatType.ADS))
	reach_value_label.text = '%.2f%%' % (world.get_reach() * 100) #str(get_reach() * 100) + '%'


func _process(_delta):
	if world_updated:
		update()
		world_updated = false


func _on_world_info_updated(_world, _item, _value):
	world_updated = true
