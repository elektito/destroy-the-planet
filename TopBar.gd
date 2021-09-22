extends PanelContainer

onready var pollution_value_label = $margin/hbox/pollution_value_label
onready var money_label = $margin/hbox/money_label
onready var money_value_label = $margin/hbox/money_value_label

var world
var world_updated = false

func init(_world):
	world = _world
	
	world.connect("info_updated", self, "_on_world_info_updated") # warning-ignore: return_value_discarded
	
	update()


func update():
	var money_per_cycle = world.get_total_property(Global.StatType.MONEY_PER_CYCLE)
	
	money_value_label.text = Global.human_readable(world.money) + ' (+' + Global.human_readable(money_per_cycle) + ')'
	
	var tooltip = 'Money (+Money-per-Cycle): ' + str(world.money) + ' (+' + str(money_per_cycle) + ')'
	money_value_label.hint_tooltip = tooltip
	money_label.hint_tooltip = tooltip
	
	var pollution_percent = int(float(world.pollution) / world.MAX_POLLUTION * 100)
	pollution_value_label.text = str(world.pollution) + ' (' + str(pollution_percent) + '%)'


func _process(_delta):
	if world_updated:
		update()
		world_updated = false


func _on_world_info_updated(_world, _item, _value):
	world_updated = true
