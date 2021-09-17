extends PanelContainer

onready var pollution_value_label = $margin/hbox/pollution_value_label
onready var resources_value_label = $margin/hbox/resources_value_label
onready var money_label = $margin/hbox/money_label
onready var money_value_label = $margin/hbox/money_value_label

var world
var world_updated = false

func init(world):
	self.world = world
	
	var ret = world.connect("info_updated", self, "_on_world_info_updated")
	if ret != OK:
		print('Could not connect world.info_updated signal. Run for your lives!')
		get_tree().quit()
	
	update()


func update():
	var money_per_cycle = world.get_total_property(Global.StatType.MONEY_PER_CYCLE)
	
	money_value_label.text = Global.human_readable(world.money) + ' (+' + Global.human_readable(money_per_cycle) + ')'
	
	var tooltip = 'Money (+Money-per-Cycle): ' + str(world.money) + ' (+' + str(money_per_cycle) + ')'
	money_value_label.hint_tooltip = tooltip
	money_label.hint_tooltip = tooltip
	
	var resources_percent = int(float(world.resources) / world.MAX_RESOURCES * 100)
	resources_value_label.text = str(world.resources) + ' (' + str(resources_percent) + '%)'
	
	var pollution_percent = int(float(world.pollution) / world.MAX_POLLUTION * 100)
	pollution_value_label.text = str(world.pollution) + ' (' + str(pollution_percent) + '%)'


func _process(delta):
	if world_updated:
		update()
		world_updated = false


func _on_world_info_updated(world, _item, _value):
	world_updated = true
